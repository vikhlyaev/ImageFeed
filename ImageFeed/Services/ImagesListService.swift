import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    
    private lazy var dateFormatter = ISO8601DateFormatter()
    
    static let DidChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private init() {}
    
    private func prepareRequest(with page: Int) -> URLRequest? {
        guard
            let token = OAuthTokenStorage().token,
            var urlComponents = URLComponents(string: AuthConfiguration.standard.baseURLString)
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
    
    private func prepareRequest(with photoId: String, and isLike: Bool) -> URLRequest? {
        guard
            let token = OAuthTokenStorage().token,
            var urlComponents = URLComponents(string: AuthConfiguration.standard.baseURLString)
        else { return nil }
        urlComponents.path = "/photos/\(photoId)/like"
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage(_ completion: @escaping (Error?) -> Void) {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        
        let сompletionOnMainQueue: (Error?) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard task == nil else { return }

        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        guard let request = prepareRequest(with: nextPage) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map {
                    let createdDate = self.dateFormatter.date(from: $0.createdAt)
                    var newPhoto = Photo(from: $0)
                    newPhoto.createdAt = createdDate
                    return newPhoto
                }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                NotificationCenter.default
                    .post(
                        name: ImagesListService.DidChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos])
                сompletionOnMainQueue(nil)
            case .failure(let error):
                print(error)
                сompletionOnMainQueue(error)
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let сompletionOnMainQueue: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let request = prepareRequest(with: photoId, and: isLiked) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UnsplashResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(_):
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked)
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                сompletionOnMainQueue(.success(()))
            case .failure(let error):
                сompletionOnMainQueue(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func clean() {
        task = nil
        photos = []
        lastLoadedPage = nil
    }
}
