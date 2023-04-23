import Foundation

final class WebPresenter {
    
    weak var viewInput: WebViewInput?
    
    private func makeRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: AuthConfiguration.standart.authorizeURLString) else {
            throw AppError.Network.badRequest
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AuthConfiguration.standart.accessKey),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standart.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AuthConfiguration.standart.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            throw AppError.Network.badRequest
        }
        
        didUpdateProgressValue(0)
        
        return URLRequest(url: url)
    }
    
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}

// MARK: - WebViewOutput

extension WebPresenter: WebViewOutput {
    func viewIsReady() {
        do {
            let request = try makeRequest()
            viewInput?.load(on: request)
        } catch {
            viewInput?.showErrorAlert()
        }
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        viewInput?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        viewInput?.setProgressHidden(shouldHideProgress)
    }
    
    func fetchCode(from url: URL) -> String? {
        guard let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
              let codeItem = items.first(where: { $0.name == "code" }),
              let code = codeItem.value
        else { return nil }
        return code
    }
}
