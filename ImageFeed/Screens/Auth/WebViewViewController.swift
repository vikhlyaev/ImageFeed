import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        print(#function)
    }
}
