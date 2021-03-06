import UIKit
import Cartography

class RepoCell: UITableViewCell {
    private let repoNamelabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.preferredFont(forTextStyle: .title1)
        view.adjustsFontSizeToFitWidth = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.minimumScaleFactor = 0.2        
        return view
    }()
    private let ownerNameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
         view.font = UIFont.preferredFont(forTextStyle: .body)
        return view
    }()
    private let starsLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textAlignment = .right
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.font = UIFont.preferredFont(forTextStyle: .caption1)
        return view
    }()
    private let ownerPictureImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        addSubview(repoNamelabel)
        addSubview(ownerNameLabel)
        addSubview(starsLabel)
        addSubview(ownerPictureImageView)
        
        constrain(repoNamelabel, ownerNameLabel, starsLabel, ownerPictureImageView, self) { repoName, ownerName, stars, ownerPicture, container in
            repoName.leading == container.leading + 16
            repoName.top == container.top + 16
            repoName.trailing == stars.leading - 8
            stars.trailing == container.trailing - 16
            stars.centerY == repoName.centerY
            
            ownerPicture.top == repoName.bottom + 8
            ownerPicture.width == 80
            ownerPicture.height == 80
            ownerPicture.leading == container.leading + 16
            ownerPicture.bottom == container.bottom - 16
            
            ownerName.top == ownerPicture.top
            ownerName.leading == ownerPicture.trailing + 8
            ownerName.trailing == container.trailing - 16
            ownerName.bottom == ownerPicture.bottom
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RepoCell {
    func configure(with repo: Repo) {
        repoNamelabel.text = repo.name
        ownerNameLabel.text = repo.owner.login
        ownerPictureImageView.sd_setImage(with: repo.owner.avatarUrl, completed: nil)
        starsLabel.text = "★ " + repo.stargazersCount.description
    }
}
