import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewIsReady() throws {
        // given
        let webPresenterSpy = WebPresenterSpy()
        let viewController = WebViewController(output: webPresenterSpy)
        webPresenterSpy.viewInput = viewController
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(webPresenterSpy.viewIsReadyCalled)
    }
    
    func testPresenterCallsLoadOnRequest() throws {
        // given
        let presenter = WebPresenter(authService: AuthServiceImpl())
        let viewController = WebViewControllerSpy()
        presenter.viewInput = viewController
        // when
        presenter.viewIsReady()
        // then
        XCTAssertTrue(viewController.loadOnRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let presenter = WebPresenter(authService: AuthServiceImpl())
        let progress: Float = 0.6
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressVisibleWhenGreaterThanOne() {
        //given
        let presenter = WebPresenter(authService: AuthServiceImpl())
        let progress: Float = 1
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authService = AuthServiceImpl(configuration: configuration)
        
        //when
        guard
            let request = try? authService.authRequest(),
            let url = request.url
        else {
            return
        }
        
        let urlString = url.absoluteString
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authorizeURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authService = AuthServiceImpl(configuration: configuration)
        let urlString = "https://unsplash.com/oauth/authorize/native"
        var urlComponents = URLComponents(string: urlString)
        
        // when
        urlComponents?.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = urlComponents?.url else { return }
        
        // then
        XCTAssertEqual("test code", authService.code(from: url))
    }
    
}

final class WebPresenterSpy: WebViewOutput {
    var viewIsReadyCalled: Bool = false
    var viewInput: WebViewInput?
    
    func viewIsReady() {
        viewIsReadyCalled = true
    }
    
    func fetchCode(from url: URL) -> String? { nil }
    func didUpdateProgressValue(_ newValue: Double) { }
}

final class WebViewControllerSpy: WebViewInput {
    var loadOnRequestCalled: Bool = false
    
    func load(on request: URLRequest) {
        loadOnRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) { }
    func setProgressHidden(_ isHidden: Bool) { }
    func showErrorAlert() { }
}
