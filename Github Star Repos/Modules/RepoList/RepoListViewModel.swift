import Foundation
import RxSwift
import RxDataSources

class RepoListViewModel {
    enum ViewState {
        case loading
        case loaded
        case error
    }
    
    // MARK:- Observables
    
    let observableResult = BehaviorSubject<Result<RepoSearchResponse>?>(value: nil)
    
    var viewTitle: Observable<String> = Observable.just(.viewTitle)
    
    var viewState: Observable<ViewState> {
        return observableResult.map { result in
            if case .success? = result {
                return .loaded
            } else if case .failure? = result {
                return .error
            } else {
                return .loading
            }
        }
    }
    
    var errorMessage: Observable<String?> {
        return observableResult.map { result in
            guard case .failure(let error)? = result else {
                return nil
            }
            return error.localizedDescription
        }
    }
    
    private var repos: [Repo] = []
    var observableRepos: Observable<[SectionModel<Int, ListItem>]> {
        return observableResult.map { result in
            guard case .success(let response)? = result else {
                return []
            }
            self.repos += response.items
            let items: [ListItem] = self.repos.map({ (repo) -> ListItem in
                return .model(repo: repo) }) + (self.shouldFetchMorePages ? [.loader] : [])
            return [SectionModel(model: 0, items: items)]
        }
    }
    
    // MARK:- Paging requests
    
    private let perPage = 20
    private var currentPage = 1
    private var totalCount: Int? = nil
    
    private var shouldFetchMorePages: Bool {
        guard let totalCount = totalCount else {
            print("ERROR: Trying to check for more pages without total info.")
            return false
        }
        return currentPage*perPage - totalCount < perPage
    }
    
    private func fetchCurrentPage() {
        if let url = Endpoint.searchSwiftRepos(currentPage: currentPage, perPage: perPage).url {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    self?.observableResult.onNext(.failure(error))
                } else if let data = data {
                    do {
                        let response = try JSONDecoder().decode(RepoSearchResponse.self, from: data)
                        self?.currentPage += 1
                        self?.totalCount = response.totalCount
                        
                        self?.observableResult.onNext(.success(response))
                    } catch (let e) {
                        self?.observableResult.onNext(.failure(e))
                    }
                }
            }
            task.resume()
        }
    }
    
    private func fetchNextPageIfNeeded() {
        guard shouldFetchMorePages else {
            print("DEBUG: Reached end of list.")
            return
        }
        fetchCurrentPage()
    }
    
    func refresh() {
        currentPage = 1
        totalCount = nil
        fetchCurrentPage()
    }
    
    func userReachedEndOfTheList() {
        fetchNextPageIfNeeded()
    }
    
    // MARK:- Initialization
    
    init() {
        fetchCurrentPage()
    }
}

fileprivate extension String {
    static let viewTitle = NSLocalizedString("Swift Star Repos", comment: "Repo list view title.")
}
