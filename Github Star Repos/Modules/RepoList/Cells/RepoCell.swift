import UIKit
import Cartography

class RepoCell: UITableViewCell {
    let repoNamelabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title1)
        return view
    }()
    let ownerNameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
         view.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        return view
    }()
    let starsLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
        return view
    }()
    let ownerPictureImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        addSubview(repoNamelabel)
        addSubview(ownerNameLabel)
        addSubview(starsLabel)
        addSubview(ownerPictureImageView)
        
        constrain(repoNamelabel, ownerNameLabel, starsLabel, ownerPictureImageView, self) { repoName, ownerName, stars, ownerPicture, container in
            repoName.leading == container.leading + 16
            repoName.top == container.top + 16
            repoName.trailing == stars.leading
            stars.trailing == container.trailing - 16
            stars.centerY == repoName.centerY
            
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
