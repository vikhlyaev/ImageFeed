import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let session: URLSession
    private let decoder: JSONDecoder
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() {
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
    }
    
    private func prepareRequest() -> URLRequest? {
        guard let token = OAuthTokenStorage().token,
              var url = Constants.baseURL
        else { return nil }
        
        if #available(iOS 16.0, *) {
            url.append(path: "/me")
        } else {
            url.appendPathComponent("/me")
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = prepareRequest() else { return }
       
        let fulfillCompletion: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    self.decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let model = try? self.decoder.decode(ProfileResult.self, from: data) {
                        let profile = Profile(username: model.username,
                                              firstName: model.firstName,
                                              lastName: model.lastName,
                                              bio: model.bio ?? "")
                        fulfillCompletion(.success(profile))
                        self.profile = profile
                        self.task = nil
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
