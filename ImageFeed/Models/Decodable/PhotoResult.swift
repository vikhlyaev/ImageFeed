import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let full: String
    let regular: String
    let thumb: String
}
