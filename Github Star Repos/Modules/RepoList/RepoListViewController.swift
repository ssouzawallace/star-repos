import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Cartography
import SDWebImage

class RepoListViewController: UIViewController {
    
    let viewModel = RepoListViewModel()
    let disposeBag = DisposeBag()
    
    let dataSource = RepoListViewController.dataSource()
    
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
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
        view.textColor = .white
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()
    
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
            error.leading >= container.leading+16
            error.trailing >= container.trailing-16
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func configureRx() {
        viewModel.viewTitle.bind(to: rx.title).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .loading }).bind(to: activityIndicator.rx.isHidden).disposed(by: disposeBag)
        viewModel.viewState.map({ $0 != .error }).bind(to: errorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.errorMessage.bind(to: errorLabel.rx.text).disposed(by: disposeBag)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        viewModel.observableRepos.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    private static func dataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<Int, ListItem>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<Int, ListItem>>(
            configureCell: { (dataSource, table, indexPath, item) in
                switch (item) {
                case .loader:
                    let cell: LoaderCell = table.dequeueReusableCell(forIndexPath: indexPath)
                    return cell
                case .model(let repo):
                    let cell: RepoCell = table.dequeueReusableCell(forIndexPath: indexPath)
                    cell.repoNamelabel.text = repo.name
                    cell.ownerNameLabel.text = repo.owner.login
                    cell.ownerPictureImageView.sd_setImage(with: repo.owner.avatarUrl, completed: nil)
                    cell.starsLabel.text = "★ " + repo.stargazersCount.description
                    return cell
                }
        })
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        viewModel.fetchData() {
            refreshControl.endRefreshing()
        }
    }
}

extension RepoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource[indexPath.section].items.count - 1 {
            viewModel.userReachedEndOfTheList()
        }
    }
}
