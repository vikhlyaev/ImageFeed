import Foundation

final class WebPresenter {
    
    weak var viewInput: WebViewInput?
    
    private let authHelper: AuthService
    
    init(authHelper: AuthService) {
        self.authHelper = authHelper
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}

// MARK: - WebViewOutput

extension WebPresenter: WebViewOutput {
    func viewIsReady() {
        do {
            let request = try authHelper.authRequest()
            viewInput?.load(on: request)
            didUpdateProgressValue(0)
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
        authHelper.code(from: url)
    }
}
