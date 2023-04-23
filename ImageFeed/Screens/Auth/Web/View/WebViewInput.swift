import Foundation

protocol WebViewInput: AnyObject {
    func load(on request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
    func showErrorAlert()
}
