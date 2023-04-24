import Foundation

protocol ProfileViewOutput {
    func viewIsReady()
    func didUpdateAvatar()
    func didLogOutButtonTapped()
    func cleanServices()
}
