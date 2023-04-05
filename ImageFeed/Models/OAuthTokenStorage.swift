import Foundation

final class OAuthTokenStorage {
    
    private let key = "accessToken"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

