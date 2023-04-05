import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthorization()
    }
    
    private func prepareURL() -> URL? {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        return urlComponents.url
    }
    
    private func loadAuthorization() {
        guard let url = prepareURL() else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction private func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
