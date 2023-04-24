import Foundation

protocol ImagesListOutput {
    var photosCount: Int { get }
    func viewIsReady()
    func didLoadNextPhoto()
    func fetchPhotos()
    func didRequestPhoto(by index: Int) -> Photo
    func didChangeLikeButtonTapped(_ cell: ImagesListCell, photoId: String, isLiked: Bool)
}
