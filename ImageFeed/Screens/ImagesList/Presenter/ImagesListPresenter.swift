import Foundation

final class ImagesListPresenter {
    weak var viewInput: ImagesListInput?
    private let imagesListService: ImagesListService
    private var photos: [Photo] = []
    
    init(imagesListService: ImagesListService) {
        self.imagesListService = imagesListService
    }
}

extension ImagesListPresenter: ImagesListOutput {
    var photosCount: Int {
        photos.count
    }
    
    func didRequestPhoto(by index: Int) -> Photo {
        photos[index]
    }
    
    func viewIsReady() {
        fetchPhotos()
    }
    
    func fetchPhotos() {
        imagesListService.fetchPhotosNextPage { [weak self] error in
            if error != nil {
                self?.viewInput?.showErrorAlert()
            }
        }
    }
    
    func didLoadNextPhoto() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            viewInput?.updateTableViewAnimated(indexes: oldCount..<newCount)
        }
    }
    
    func didChangeLikeButtonTapped(_ cell: ImagesListCell, photoId: String, isLiked: Bool) {
        imagesListService.changeLike(photoId: photoId, isLiked: isLiked) { result in
            switch result {
            case .success():
                self.photos = self.imagesListService.photos
                cell.setIsLiked(!isLiked)
                UIBlockingProgressHUB.dismiss()
            case .failure(let error):
                UIBlockingProgressHUB.dismiss()
                fatalError(error.localizedDescription)
            }
        }
    }
}
