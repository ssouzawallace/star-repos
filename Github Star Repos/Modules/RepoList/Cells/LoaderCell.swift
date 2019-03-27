import UIKit
import Cartography

class LoaderCell: UITableViewCell {
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.startAnimating()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(activityIndicator)
        
        constrain(activityIndicator, self) { spinner, container in
            spinner.center == container.center
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        activityIndicator.startAnimating()
    }
}
