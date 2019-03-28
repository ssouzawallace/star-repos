import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Cartography
import SDWebImage

class RepoListViewController: UIViewController {
    
    // MARK: Rx
    
    let viewModel = RepoListViewModel()
    let disposeBag = DisposeBag()
    
    let dataSource = RepoListViewController.dataSource()
    
    // MARK: Subviews
    
    let refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        return view
    }()
    
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.tableFooterView = UIView()
        return view
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        view.hidesWhenStopped = true
        return view
    }()
    
    let errorLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        configureSubviews()
        configureRx()
    }
    
    func registerCells() {
        tableView.register(RepoCell.self, forCellReuseIdentifier: RepoCell.reuseIdentifier)
        tableView.register(LoaderCell.self, forCellReuseIdentifier: LoaderCell.reuseIdentifier)
    }
    
    func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorLabel)
        
        constrain(tableView, activityIndicator, errorLabel, view) { table, spinner, error, container in
            table.edges == container.edges
            spinner.center == container.center
            error.center == container.center
            error.leading >= container.leading + 16
            error.trailing >= container.trailing - 16
        }
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = self.refreshControl
        tableView.allowsSelection = false
    }
    
    func configureRx() {
        viewModel.viewTitle.bind(to: rx.title).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .loading }).bind(to: activityIndicator.rx.isHidden).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .error }).bind(to: errorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.errorMessage.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.observableRepos.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 == .loading }).bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        viewModel.refresh()
    }
}

// MARK:- TableView Datasource

extension RepoListViewController {
    
    private static func dataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<Int, ListItem>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Int, ListItem>>(
            configureCell: { (dataSource, table, indexPath, item) in
                switch (item) {
                case .loader:
                    let cell: LoaderCell = table.dequeueReusableCell(forIndexPath: indexPath)
                    return cell
                case .model(let repo):
                    let cell: RepoCell = table.dequeueReusableCell(forIndexPath: indexPath)
                    cell.configure(with: repo)
                    return cell
                }
        })
    }
}

// MARK:- TableView Delegate

extension RepoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath.section].items[indexPath.row] {
        case .loader:
            return 60
        default:
            return 160
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource[indexPath.section].items.count - 1 {
            viewModel.userReachedEndOfTheList()
        }
    }
}
