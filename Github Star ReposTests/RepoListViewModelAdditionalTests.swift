import Quick
import Nimble
import RxNimble
import RxSwift
import RxDataSources
import RxTest
import OHHTTPStubs

@testable import Github_Star_Repos

class RepoListViewModelAdditionalTests: QuickSpec {

    override func spec() {

        describe("repo list view model") {

            // MARK: - View Title

            context("view title") {
                it("emits the expected title") {
                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    expect(viewModel.viewTitle).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, "Swift Star Repos"),
                                   .completed(0)]))
                }
            }

            // MARK: - Observable Repos

            context("observableRepos") {
                it("returns section with repo items on success") {
                    let owner = RepoOwner(login: "apple", avatarUrl: URL(string: "https://example.com/avatar")!)
                    let repo = Repo(name: "swift", owner: owner, stargazersCount: 60000)
                    let response = RepoSearchResponse(totalCount: 1, items: [repo])

                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    scheduler.createHotObservable([.next(10, Result.success(response))])
                        .bind(to: viewModel.observableResult)
                        .disposed(by: disposeBag)

                    var sections: [SectionModel<Int, ListItem>]?
                    viewModel.observableRepos
                        .subscribe(onNext: { sections = $0 })
                        .disposed(by: disposeBag)

                    scheduler.advanceTo(10)

                    expect(sections).toNot(beNil())
                    expect(sections?.first?.items).toNot(beEmpty())
                }

                it("returns empty sections on failure") {
                    enum TestError: Error { case test }

                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    scheduler.createHotObservable([.next(10, Result.failure(TestError.test))])
                        .bind(to: viewModel.observableResult)
                        .disposed(by: disposeBag)

                    var sections: [SectionModel<Int, ListItem>]?
                    viewModel.observableRepos
                        .subscribe(onNext: { sections = $0 })
                        .disposed(by: disposeBag)

                    scheduler.advanceTo(10)

                    expect(sections).toNot(beNil())
                    expect(sections ?? []).to(beEmpty())
                }
            }

            // MARK: - View State with nil result

            context("initial state") {
                it("starts in loading state") {
                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    // Don't send any result - viewModel should remain in loading state
                    scheduler.createHotObservable([Recorded<Event<Result<RepoSearchResponse>?>>]())
                        .bind(to: viewModel.observableResult)
                        .disposed(by: disposeBag)

                    expect(viewModel.viewState).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, .loading)]))
                }

                it("starts with nil error message") {
                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    scheduler.createHotObservable([Recorded<Event<Result<RepoSearchResponse>?>>]())
                        .bind(to: viewModel.observableResult)
                        .disposed(by: disposeBag)

                    expect(viewModel.errorMessage).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, nil)]))
                }
            }

            // MARK: - Transitions

            context("state transitions") {
                it("transitions from loading to loaded then back to loading on nil") {
                    let response = RepoSearchResponse(totalCount: 0, items: [])

                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    scheduler.createHotObservable([
                        .next(10, Result.success(response)),
                        .next(20, nil)
                    ]).bind(to: viewModel.observableResult)
                      .disposed(by: disposeBag)

                    expect(viewModel.viewState).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, .loading),
                                   .next(10, .loaded),
                                   .next(20, .loading)]))
                }

                it("transitions from error state back to loaded on success") {
                    enum TestError: Error { case test }
                    let response = RepoSearchResponse(totalCount: 0, items: [])

                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    scheduler.createHotObservable([
                        .next(10, Result.failure(TestError.test)),
                        .next(20, Result.success(response))
                    ]).bind(to: viewModel.observableResult)
                      .disposed(by: disposeBag)

                    expect(viewModel.viewState).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, .loading),
                                   .next(10, .error),
                                   .next(20, .loaded)]))
                }

                it("clears error message when transitioning from error to success") {
                    enum TestError: Error { case test }
                    let response = RepoSearchResponse(totalCount: 0, items: [])

                    let scheduler = TestScheduler(initialClock: 0)
                    let disposeBag = DisposeBag()
                    let viewModel = RepoListViewModel()

                    scheduler.createHotObservable([
                        .next(10, Result.failure(TestError.test)),
                        .next(20, Result.success(response))
                    ]).bind(to: viewModel.observableResult)
                      .disposed(by: disposeBag)

                    expect(viewModel.errorMessage).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, nil),
                                   .next(10, TestError.test.localizedDescription),
                                   .next(20, nil)]))
                }
            }
        }
    }
}
