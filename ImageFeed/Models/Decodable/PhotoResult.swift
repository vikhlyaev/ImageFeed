import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let likedByUser: Bool?
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case createdAt = "created_at"
        case width = "width"
        case height = "height"
        case description = "description"
        case urls = "urls"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let full: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case full = "full"
        case thumb = "thumb"
    }
}
