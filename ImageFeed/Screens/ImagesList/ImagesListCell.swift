import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView! {
        didSet {
            addGradient()
        }
    }
    
    static let identifier = String(describing: ImagesListCell.self)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction private func likeButtonTapped(_ sender: UIButton) {
        print("likeButtonTapped")
    }
    
    private func addGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0).cgColor,
                           UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0.2).cgColor]
        gradient.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradient)
    }
}
