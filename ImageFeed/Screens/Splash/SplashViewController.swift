import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "YandexPracticum")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let segueIdentifier = "ShowAuthenticationScreenSegueIdentifier"
    private let oauthService = OAuthService()
    private let oauthTokenStorage = OAuthTokenStorage()
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setConstraints()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "customBlack")
        view.addSubview(logoImageView)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func loadProfile() {
        if let token = oauthTokenStorage.token {
            fetchProfile(token: token)
        } else {
            let authViewController = AuthViewController()
            let navigationController = UINavigationController(rootViewController: authViewController)
            authViewController.delegate = self
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let profile):
                UIBlockingProgressHUB.dismiss()
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUB.dismiss()
                showErrorAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUB.show()
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauthService.fetchAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let token):
                self.oauthTokenStorage.token = token
                self.fetchProfile(token: token)
            case .failure:
                UIBlockingProgressHUB.dismiss()
                showErrorAlert()
            }
        }
    }
}

// MARK: - Setting Constraints

extension SplashViewController {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
