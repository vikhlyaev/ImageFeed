import Foundation

final class ImagesListService {
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let DidChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private func prepareRequest(with page: Int) -> URLRequest? {
        guard
            let token = OAuthTokenStorage().token,
            var urlComponents = URLComponents(string: Constants.baseURLString)
        else { return nil }
        urlComponents.path = "/photos"
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void) {
        assert(Thread.isMainThread)
        let nextPage = lastLoadedPage != nil ? lastLoadedPage ?? 0 + 1 : 1
        guard let request = prepareRequest(with: nextPage) else { return }

        let сompletionOnMainQueue: (Result<[Photo], Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.task = nil
                self.lastLoadedPage = nextPage
                NotificationCenter.default
                    .post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos])
                сompletionOnMainQueue(.success(newPhotos))
            case .failure(let error):
                сompletionOnMainQueue(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}
