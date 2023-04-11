import UIKit
import WebKit

protocol WebViewControllerDelegate: AnyObject {
    func webViewController(_ vc: WebViewController, didAuthenticateWithCode code: String)
    func webViewControllerDidCancel(_ vc: WebViewController)
}

final class WebViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    private let authService = OAuthService()
    
    weak var delegate: WebViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWebViewDelegate()
        loadAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverProgress()
        updateProgress()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserverProgress()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        delegate?.webViewControllerDidCancel(self)
    }
    
    private func setWebViewDelegate() {
        webView.navigationDelegate = self
    }
    
    private func prepareRequest() -> URLRequest? {
        guard let url = Constants.authorizeURLString,
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    private func loadAuthorization() {
        guard let request = prepareRequest() else { return }
        webView.load(request)
    }
    
    private func addObserverProgress() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func removeObserverProgress() {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
