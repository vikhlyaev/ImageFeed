import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewIsReady() {
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController(output: presenter)
        presenter.viewInput = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewIsReadyCalled)
    }
    
    func testPresenterCallsPhotoCount() {
        let presenter = ImagesListPresenterSpy()
        
        XCTAssertEqual(presenter.photosCount, 1)
    }
    
    func testPresenterCallsDidLoadNextPhoto() {
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController(output: presenter)
        presenter.viewInput = viewController
        
        presenter.didLoadNextPhoto()

        XCTAssertTrue(presenter.didLoadNextPhotoCalled)
    }
    
    func testPresenterCallsFetchPhotos() {
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController(output: presenter)
        presenter.viewInput = viewController
        
        presenter.fetchPhotos()

        XCTAssertTrue(presenter.fetchPhotosCalled)
    }
    
    func testPresenterCallsDidRequestPhoto() {
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController(output: presenter)
        presenter.viewInput = viewController
        
        let profile = presenter.didRequestPhoto(by: 1)
        
        XCTAssertEqual(profile.id, "")
    }
}

final class ImagesListPresenterSpy: ImagesListOutput {
    
    var viewInput: ImagesListInput?
    
    var viewIsReadyCalled: Bool = false
    var didLoadNextPhotoCalled: Bool = false
    var fetchPhotosCalled: Bool = false
    
    var photosCount: Int {
        1
    }
    
    func viewIsReady() {
        viewIsReadyCalled = true
    }
    
    func didLoadNextPhoto() {
        didLoadNextPhotoCalled = true
    }
    
    func fetchPhotos() {
        fetchPhotosCalled = true
    }
    
    func didRequestPhoto(by index: Int) -> ImageFeed.Photo {
        Photo(id: "",
              size: CGSize(width: 111, height: 111),
              createdAt: Date(),
              welcomeDescription: "",
              thumbImageURL: "",
              largeImageURL: "",
              isLiked: true)
    }
    
    func didChangeLikeButtonTapped(_ cell: ImageFeed.ImagesListCell, photoId: String, isLiked: Bool) {}
}
