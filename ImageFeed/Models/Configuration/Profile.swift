import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, firstName: String, lastName: String, bio: String) {
        self.username = username
        self.name = "\(firstName) \(lastName)"
        self.loginName = "@\(username)"
        self.bio = bio
    }
}
