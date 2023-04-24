import Foundation

protocol AuthService {
    func authRequest() throws -> URLRequest
    func code(from url: URL) -> String?
}
