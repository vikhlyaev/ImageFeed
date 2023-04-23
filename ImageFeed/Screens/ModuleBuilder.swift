import UIKit

final class ModuleBuilder {
    
    static func makeWebModule(delegate: WebViewControllerDelegate) -> UIViewController {
        let presenter = WebPresenter()
        let vc = WebViewController(output: presenter)
        presenter.viewInput = vc
        vc.delegate = delegate
        return vc
    }
    
}


