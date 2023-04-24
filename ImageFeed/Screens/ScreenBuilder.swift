import UIKit

final class ScreenBuilder {
    
    static let shared = ScreenBuilder()
    
    private let authHelper: AuthService = AuthServiceImpl()
    
    private init() {}
    
    func makeWebScreen(delegate: WebViewControllerDelegate) -> UIViewController {
        let presenter = WebPresenter(authHelper: authHelper)
        let vc = WebViewController(output: presenter)
        presenter.viewInput = vc
        vc.delegate = delegate
        return vc
    }
    
    func makeProfileScreen() -> UIViewController {
        let presenter = ProfilePresenter()
        let vc = ProfileViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
    func makeImagesListScreen() -> UIViewController {
        let presenter = ImagesListPresenter()
        let vc = ImagesListViewController(output: presenter)
        presenter.viewInput = vc
        return vc
    }
    
}


