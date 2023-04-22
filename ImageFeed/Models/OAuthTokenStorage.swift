import Foundation
import SwiftKeychainWrapper

final class OAuthTokenStorage {
    
    private let key = "accessToken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: key)
        }
        set {
            guard let newValue = newValue else { return }
            KeychainWrapper.standard.set(newValue, forKey: key)
        }
    }
    
    static func clean() {
        KeychainWrapper.standard.removeAllKeys()
    }
}

