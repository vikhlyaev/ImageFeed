import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else { fatalError("Failed to prepare for \(segueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
            performSegue(withIdentifier: segueIdentifier, sender: nil)
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
