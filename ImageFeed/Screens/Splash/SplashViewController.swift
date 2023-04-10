import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let segueIdentifier = "ShowAuthenticationScreenSegueIdentifier"
    private let oauthService = OAuthService()
    private let profileService = ProfileService.shared
    private let oauthTokenStorage = OAuthTokenStorage()
    
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
            switch result {
            case .success(let token):
                self?.oauthTokenStorage.token = token
                self?.fetchProfile(token: token)
            case .failure(let error):
                UIBlockingProgressHUB.dismiss()
                // TODO: временный принт
                print(error)
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUB.dismiss()
                self.switchToTabBarController()
            case .failure(let error):
                UIBlockingProgressHUB.dismiss()
                // TODO: временный принт
                print(error)
            }
        }
    }
}
