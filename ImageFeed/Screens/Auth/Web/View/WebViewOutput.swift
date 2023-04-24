import Foundation

protocol WebViewOutput {
    func viewIsReady()
    func didUpdateProgressValue(_ newValue: Double)
    func fetchCode(from url: URL) -> String?
}
