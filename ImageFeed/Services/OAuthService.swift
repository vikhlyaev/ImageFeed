import Foundation

final class OAuthService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private var lastCode: String?
    private var task: URLSessionTask?
    
    init(session: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    private func prepareRequest(code: String) -> URLRequest? {
        guard let url = Constants.tokenURLString,
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
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
        
        let fulfillCompletion: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        checkLastCode(code: code)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    self?.decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let model = try? self?.decoder.decode(OAuthTokenResponseBody.self, from: data) {
                        fulfillCompletion(.success(model.accessToken))
                        self?.task = nil
                    }
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
                self?.lastCode = nil
            }
        }
        
        self.task = task
        task.resume()
    }
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}
