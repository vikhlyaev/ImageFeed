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
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let fulfillCompletion: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let url = try? prepareURL(code: code) else { completion(.failure(NetworkError.badURL)); return }
        let request = makeRequest(url: url)
        
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
    
    private func prepareURL(code: String) throws -> URL {
        guard var urlComponents = URLComponents(string: Constants.tokenURLString) else { throw NetworkError.badURLComponents }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url else { throw NetworkError.badURL }
        return url
    }
    
    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case badURLComponents
    case badURL
}
