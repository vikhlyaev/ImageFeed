import Foundation

struct Constants {
    static let accessKey = "ugMqz4pOBvfxQ3OYf9Zftj95xymv9vESsYZtj3pvVwA"
    static let secretKey = "Hf3LM5kly0LsGfVAGUPhkESuAaLYfukc_-mWXWYRwHo"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let authorizeURLString = URL(string: "https://unsplash.com/oauth/authorize")
    static let tokenURLString = URL(string: "https://unsplash.com/oauth/token")
    static let baseURL = URL(string: "https://api.unsplash.com")
}
