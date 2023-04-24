import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var unsplashLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "UnsplashLogo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        button.tintColor = .customBlack
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitle("Войти", for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "Authenticate"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .customBlack
        view.addSubview(unsplashLogoImageView)
        view.addSubview(loginButton)
    }
    
    @objc
    private func loginButtonTapped() {
        let webViewController = ScreenBuilder.shared.makeWebScreen(delegate: self)
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }
}

// MARK: - WebViewControllerDelegate

extension AuthViewController: WebViewControllerDelegate {
    func webViewController(_ vc: WebViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewControllerDidCancel(_ vc: WebViewController) {
        dismiss(animated: true)
    }
}

// MARK: - Setting Constraints

extension AuthViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            unsplashLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unsplashLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            unsplashLogoImageView.widthAnchor.constraint(equalToConstant: 60),
            unsplashLogoImageView.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

