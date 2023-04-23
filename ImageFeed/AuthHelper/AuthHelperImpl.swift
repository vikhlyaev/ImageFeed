import Foundation

final class AuthHelperImpl {
    
    private let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = AuthConfiguration.standard) {
        self.configuration = configuration
    }
    
}

extension AuthHelperImpl: AuthHelper {
    func authRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: configuration.authorizeURLString) else {
            throw AppError.Network.badRequest
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            throw AppError.Network.badRequest
        }
        
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        guard let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
              let codeItem = items.first(where: { $0.name == "code" }),
              let code = codeItem.value
        else { return nil }
        return code
    }
    
}
