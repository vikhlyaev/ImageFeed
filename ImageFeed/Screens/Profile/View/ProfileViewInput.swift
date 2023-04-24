import Foundation

protocol ProfileViewInput: AnyObject {
    func updateUI(from profile: Profile)
    func updateAvatar(with url: URL)
    func showLogOutAlert()
}
