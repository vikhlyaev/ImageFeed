import UIKit

final class ProfileViewController: UIViewController {
    
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ProfilePhoto")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var logOutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "LogOutButton"), for: .normal)
        button.addTarget(self, action: #selector(logOutTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var photoAndLogOutButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [photoImageView, logOutButton])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor(named: "customGrey")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [photoAndLogOutButtonStackView,
                                                       nameLabel,
                                                       usernameLabel,
                                                       infoLabel])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "customBlack")
        view.addSubview(contentStackView)
    }
    
    @objc
    private func logOutTapped() {
        print("logOutTapped")
    }
}

// MARK: - Setting Constraints

extension ProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photoAndLogOutButtonStackView.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            photoAndLogOutButtonStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            photoAndLogOutButtonStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor, constant: -8),

            logOutButton.widthAnchor.constraint(equalToConstant: 24),
            logOutButton.heightAnchor.constraint(equalToConstant: 24),
            
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
