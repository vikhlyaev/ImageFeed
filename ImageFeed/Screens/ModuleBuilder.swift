import UIKit

final class ModuleBuilder {
    
    static let shared = ModuleBuilder()
    
    private let authHelper: AuthHelper = AuthHelperImpl(configuration: AuthConfiguration.standart)
    
    private init() {}
    
    func makeWebModule(delegate: WebViewControllerDelegate) -> UIViewController {
        let presenter = WebPresenter(authHelper: authHelper)
        let vc = WebViewController(output: presenter)
        presenter.viewInput = vc
        vc.delegate = delegate
        return vc
    }
    
}


