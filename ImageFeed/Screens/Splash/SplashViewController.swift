import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let segueIdentifier = "ShowAuthenticationScreenSegueIdentifier"
    private let oauthService = OAuthService()
    private let oauthTokenStorage = OAuthTokenStorage()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauthTokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
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
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        ProgressHUD.animationType = .singleCirclePulse
        ProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauthService.fetchAuthToken(code) { [weak self] result in
            switch result {
            case .success:
                self?.switchToTabBarController()
                ProgressHUD.dismiss()
            case .failure(let error):
                // временный принт
                print(error)
            }
        }
    }
}
