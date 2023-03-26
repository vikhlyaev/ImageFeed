import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView! {
        didSet {
            addGradient()
        }
    }
    
    static let identifier = String(describing: ImagesListCell.self)
    
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
    
    func configure(with model: ImagesListCellViewModel) {
        cellImageView.image = model.image
        dateLabel.text = model.date
        likeButton.setImage(model.likeButtonImage, for: .normal)
    }
}
