import Quick
import Nimble
import RxNimble
import RxSwift
import RxDataSources
import RxTest
import OHHTTPStubs

@testable import Github_Star_Repos

class Github_Star_ReposTests: QuickSpec {
    
    override func spec() {
        describe("repo list view model") {
            context("receiving succesful response") {
                
                let response: RepoSearchResponse = RepoSearchResponse(totalCount: 100,
                                                                      items: [Repo(name: "teste", owner: RepoOwner(login: "teste", avatarUrl: URL(string: "https://www.google.com.br")!), stargazersCount: 100)])
                
                let scheduler = TestScheduler(initialClock: 0)
                let disposeBag = DisposeBag()
                var viewModel: RepoListViewModel!
                
                beforeEach {
                    viewModel = RepoListViewModel()
                    scheduler.createHotObservable([.next(10, Result.success(response))])
                        .bind(to: viewModel.observableResult)
                        .disposed(by: disposeBag)
                }
                afterEach {
                    scheduler.advanceTo(0)
                }

                it("view state sequence") {
                    expect(viewModel.viewState).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, .loading),
                                   .next(10, .loaded)]))
                }
                it("error message sequence") {
                    expect(viewModel.errorMessage).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, nil),
                                   .next(10, nil)]))
                }
            }
            
            context("receiving failed response") {
                enum TestError: String, Error {
                    case testError = "test error"
                }
                
                let scheduler = TestScheduler(initialClock: 0)
                let disposeBag = DisposeBag()
                var viewModel: RepoListViewModel!
                
                beforeEach {
                    viewModel = RepoListViewModel()
                    scheduler.createHotObservable([.next(10, Result.failure(TestError.testError))])
                        .bind(to: viewModel.observableResult)
                        .disposed(by: disposeBag)
                }
                afterEach {
                    scheduler.advanceTo(0)
                }
                
                it("view state sequence") {
                    expect(viewModel.viewState).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, .loading),
                                   .next(10, .error)]))
                }
                it("error message sequence") {
                    expect(viewModel.errorMessage).events(scheduler: scheduler, disposeBag: disposeBag)
                        .to(equal([.next(0, nil),
                                   .next(10, TestError.testError.localizedDescription)]))
                }
            }
            
            context("networking") {
                afterEach {
                    OHHTTPStubs.removeAllStubs()
                }
                
                it("receiving mocked response") {
                    stub(condition: isHost("api.github.com")) { request in
                        return OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("mock_response.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                        )
                    }
                    
                    let viewModel = RepoListViewModel()
                    let decoder = JSONDecoder()
                    let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "mock_response", ofType: "json")!))
                    let response = try! decoder.decode(RepoSearchResponse.self, from: data)
                    
                    sleep(3)
                    
                    guard case Result.success(let value) = try! viewModel.observableResult.value()! else {
                        fail()
                        return
                    }
                    expect(value).to(equal(response))
                }
                
                it("bad network") {
                    stub(condition: isHost("api.github.com")) { request in
                        return OHHTTPStubsResponse(data: Data(), statusCode: 400, headers: nil)
                            .responseTime(OHHTTPStubsDownloadSpeed3G)
                    }
                    
                    let viewModel = RepoListViewModel()
                    
                    sleep(3)
                    
                    guard case Result.failure(let error) = try! viewModel.observableResult.value()! else {
                        fail()
                        return
                    }
                    
                    expect(error).to(beAKindOf(DecodingError.self))
                }
            }
        }
    }

}
