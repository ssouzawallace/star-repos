import Foundation
import RxSwift
import RxDataSources

class RepoListViewModel {
    enum ViewState {
        case loading
        case loaded
        case error
    }
    
    private let observableResult = BehaviorSubject<Result<RepoSearchResponse>?>(value: nil)
    
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
                return .model(repo: repo) }) + (self.currentPage*self.perPage - self.totalCount < self.perPage ? [.loader] : [])
            return [SectionModel(model: 0, items: items)]
        }
    }
    
    private let perPage = 20
    private var currentPage = 1
    private var totalCount = -1
    
    func fetchNextPageIfNeeded(_ finished: (()->())? = nil) {
        guard totalCount == -1 || currentPage*perPage - totalCount < perPage else {
            return
        }
        
        if let url = Endpoint.searchSwiftRepos(currentPage: currentPage, perPage: perPage).url {
            currentPage += 1
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print(error)
                } else if let data = data {
                    let response = try! JSONDecoder().decode(RepoSearchResponse.self, from: data)
                    self?.observableResult.onNext(.success(response))
                    self?.currentPage += 1
                    self?.totalCount = response.totalCount
                }
                DispatchQueue.main.async {
                    finished?()
                }
                
            }
            task.resume()
        }
    }
    
    func fetchData(_ finished: (()->())? = nil) {
        currentPage = 1
        totalCount = -1
        fetchNextPageIfNeeded(finished)
    }
    
    func userReachedEndOfTheList() {
        fetchNextPageIfNeeded()
    }
    
    init() {
        fetchData()
    }
}

enum ListItem {
    case loader
    case model(repo: Repo)
}

fileprivate extension String {
    static let viewTitle = NSLocalizedString("Swift Star Repos", comment: "Repo list view title.")
}
