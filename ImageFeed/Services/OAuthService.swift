import Foundation

final class OAuthService {
    private var lastCode: String?
    private var task: URLSessionTask?
    
    private func prepareRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: AuthConfiguration.standard.tokenURLString)
        else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AuthConfiguration.standard.accessKey),
            URLQueryItem(name: "client_secret", value: AuthConfiguration.standard.secretKey),
            URLQueryItem(name: "redirect_uri", value: AuthConfiguration.standard.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    private func checkLastCode(code: String) {
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
    }
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let request = prepareRequest(code: code) else { return }
        
        let сompletionOnMainQueue: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        checkLastCode(code: code)
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let model):
                let token = model.accessToken
                сompletionOnMainQueue(.success(token))
            case .failure(let error):
                сompletionOnMainQueue(.failure(error))
                self?.lastCode = nil
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
}
