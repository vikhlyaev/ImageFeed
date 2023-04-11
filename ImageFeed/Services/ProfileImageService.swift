import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private let session: URLSession
    private let decoder: JSONDecoder
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private init() {
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
    }
    
    private func prepareRequest(username: String) -> URLRequest? {
        guard let token = OAuthTokenStorage().token,
              var url = Constants.baseURL
        else { return nil }
        
        if #available(iOS 16.0, *) {
            url.append(path: "/users/\(username)")
        } else {
            url.appendPathComponent("/users/\(username)")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = prepareRequest(username: username) else { return }
        
        let fulfillCompletion: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let model = try? self.decoder.decode(UserResult.self, from: data) {
                        fulfillCompletion(.success(model.profileImage.small))
                        self.avatarURL = model.profileImage.small
                        self.task = nil
                        guard let avatarURL else { return }
                        NotificationCenter.default
                            .post(
                                name: ProfileImageService.DidChangeNotification,
                                object: self,
                                userInfo: ["URL": avatarURL])
                    }
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        }
        
        self.task = task
        task.resume()
    }
}
