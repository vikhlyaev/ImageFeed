import Foundation

final class ProfileService {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    static let shared = ProfileService()
    
    private init() {
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let fulfillCompletion: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        guard var url = Constants.baseURL else { return }
        if #available(iOS 16.0, *) {
            url.append(path: "/me")
        } else {
            url.appendPathComponent("/me")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
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
