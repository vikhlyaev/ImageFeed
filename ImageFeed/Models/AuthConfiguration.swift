import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authorizeURLString: String
    let tokenURLString: String
    let baseURLString: String
    
    static var standart: AuthConfiguration {
        AuthConfiguration(
            accessKey: Secrets.accessKey,
            secretKey: Secrets.secretKey,
            redirectURI: Secrets.redirectURI,
            accessScope: Secrets.accessScope,
            authorizeURLString: Secrets.authorizeURLString,
            tokenURLString: Secrets.tokenURLString,
            baseURLString: Secrets.baseURLString
        )
    }
}
