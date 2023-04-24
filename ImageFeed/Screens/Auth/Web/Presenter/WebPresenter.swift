import Foundation

final class WebPresenter {
    weak var viewInput: WebViewInput?
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    private func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
}

// MARK: - WebViewOutput

extension WebPresenter: WebViewOutput {
    func viewIsReady() {
        do {
            let request = try authService.authRequest()
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
        authService.code(from: url)
    }
}
