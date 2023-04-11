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
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor(named: "customGrey")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
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
    
    private let profileService = ProfileService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()
        addProfileAvatarObserver()
        updateUI(from: profileService.profile)
        updateAvatar()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "customBlack")
        view.addSubview(contentStackView)
    }
    
    @objc
    private func logOutTapped() {
        print("logOutTapped")
    }
    
    private func updateUI(from profile: Profile?) {
        guard let profile else { return }
        nameLabel.text = profile.name
        usernameLabel.text = profile.loginName
        infoLabel.text = profile.bio
    }
    
    private func addProfileAvatarObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        print(url)
        // TODO: Обновить аватар, используя Kingfisher
    }
}

// MARK: - Setting Constraints

extension ProfileViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photoAndLogOutButtonStackView.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            photoAndLogOutButtonStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            photoAndLogOutButtonStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            
            logOutButton.widthAnchor.constraint(equalToConstant: 44),
            logOutButton.heightAnchor.constraint(equalToConstant: 44),
            
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
