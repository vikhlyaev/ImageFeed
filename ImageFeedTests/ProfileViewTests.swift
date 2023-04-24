import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewIsReady() throws {
        // given
        let profilePresenterSpy = ProfilePresenterSpy()
        let viewController = ProfileViewController(output: profilePresenterSpy)
        profilePresenterSpy.viewInput = viewController
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(profilePresenterSpy.viewIsReadyCalled)
    }
    
    func testViewControllerCallsCleanServices() throws {
        // given
        let profilePresenterSpy = ProfilePresenterSpy()
        let viewController = ProfileViewController(output: profilePresenterSpy)
        profilePresenterSpy.viewInput = viewController
        // when
        profilePresenterSpy.cleanServices()
        // then
        XCTAssertTrue(profilePresenterSpy.cleanServicesCalled)
    }
    
    func testViewControllerCallsDidUpdateAvatar() throws {
        // given
        let profilePresenterSpy = ProfilePresenterSpy()
        let viewController = ProfileViewController(output: profilePresenterSpy)
        profilePresenterSpy.viewInput = viewController
        // when
        profilePresenterSpy.didUpdateAvatar()
        // then
        XCTAssertTrue(profilePresenterSpy.didUpdateAvatarCalled)
    }
    
    func testViewControllerCallsDidLogOutButtonTapped() throws {
        // given
        let profilePresenterSpy = ProfilePresenterSpy()
        let viewController = ProfileViewController(output: profilePresenterSpy)
        profilePresenterSpy.viewInput = viewController
        // when
        profilePresenterSpy.didLogOutButtonTapped()
        // then
        XCTAssertTrue(profilePresenterSpy.didLogOutButtonTappedCalled)
    }
    
    func testPresenterCallsUpdateUI() throws {
        // given
        let profilePresenterSpy = ProfilePresenterSpy()
        let viewController = ProfileViewControllerSpy()
        profilePresenterSpy.viewInput = viewController
        // when
        profilePresenterSpy.viewInput?.updateUI(from: Profile(username: "aaa",
                                                              firstName: "bbb",
                                                              lastName: "ccc",
                                                              bio: "ddd"))
        // then
        XCTAssertEqual(viewController.profile?.name, Optional("bbb ccc"))
    }
}

final class ProfilePresenterSpy: ProfileViewOutput {
    var viewIsReadyCalled: Bool = false
    var cleanServicesCalled: Bool = false
    var didUpdateAvatarCalled: Bool = false
    var didLogOutButtonTappedCalled: Bool = false
    
    var viewInput: ProfileViewInput?
    
    func viewIsReady() {
        viewIsReadyCalled = true
    }
    
    func didUpdateAvatar() {
        didUpdateAvatarCalled = true
    }
    
    func didLogOutButtonTapped() {
        didLogOutButtonTappedCalled = true
    }
    
    func cleanServices() {
        cleanServicesCalled = true
    }
}

final class ProfileViewControllerSpy: ProfileViewInput {
    var profile: Profile?
    var presenter = ProfilePresenterSpy()
    
    func updateUI(from profile: ImageFeed.Profile) {
        self.profile = profile
    }
    
    func updateAvatar(with url: URL) {
        
    }
    
    func showLogOutAlert() {
        
    }
}
