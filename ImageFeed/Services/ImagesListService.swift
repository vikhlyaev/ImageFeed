import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    static let DidChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private init() {}
    
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
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        let nextPage = lastLoadedPage == nil ? 1 : (lastLoadedPage ?? 0) + 1
        guard let request = prepareRequest(with: nextPage) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResults):
                print(photoResults[0].likedByUser)
                let newPhotos = photoResults.map { Photo(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.task = nil
                self.lastLoadedPage = nextPage
                NotificationCenter.default
                    .post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos])
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
        
        self.task = task
        task.resume()
    }
}
