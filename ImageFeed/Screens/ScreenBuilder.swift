import UIKit

final class ScreenBuilder {
    
    static let shared = ScreenBuilder()
    
    private let authService: AuthService = AuthServiceImpl()
    private let oauthService: OAuthService = OAuthService()
    private let oauthTokenStorage: OAuthTokenStorage = OAuthTokenStorage()
    private let profileService: ProfileService = ProfileService.shared
    private let profileImageService: ProfileImageService = ProfileImageService.shared
    private let imagesListService: ImagesListService = ImagesListService.shared
    
    private init() {}
    
    func makeWebScreen(delegate: WebViewControllerDelegate) -> UIViewController {
        let presenter = WebPresenter(authService: authService)
        let vc = WebViewController(output: presenter)
        presenter.viewInput = vc
        vc.delegate = delegate
        return vc
    }
    
    func makeProfileScreen() -> UIViewController {
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: profileImageService)
        let vc = ProfileViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makeImagesListScreen() -> UIViewController {
        let presenter = ImagesListPresenter(imagesListService: imagesListService)
        let vc = ImagesListViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makeSplashScreen() -> UIViewController {
        SplashViewController(oauthService: oauthService,
                             oauthTokenStorage: oauthTokenStorage,
                             profileService: profileService,
                             profileImageService: profileImageService)
    }
    
    func makeAuthScreen(with delegate: AuthViewControllerDelegate) -> UIViewController {
        let vc = AuthViewController()
        vc.delegate = delegate
        return vc
    }
    
    func makeSingleImageViewController(with imageUrl: String?) -> UIViewController {
        let vc = SingleImageViewController()
        vc.imageUrl = imageUrl
        return vc
    }
    
}


