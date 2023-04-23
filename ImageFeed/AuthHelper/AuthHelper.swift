import Foundation

protocol AuthHelper {
    func authRequest() throws -> URLRequest
    func code(from url: URL) -> String?
}
