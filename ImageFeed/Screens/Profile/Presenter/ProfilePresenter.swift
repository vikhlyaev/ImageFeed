import Foundation

final class ProfilePresenter {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    weak var viewInput: ProfileViewInput?
}

extension ProfilePresenter: ProfileViewOutput {
    func viewIsReady() {
        guard
            let profile = profileService.profile,
            let avatarUrlString = profileImageService.avatarURL,
            let avatarUrl = URL(string: avatarUrlString)
        else { return }
        viewInput?.updateUI(from: profile)
        viewInput?.updateAvatar(with: avatarUrl)
    }
    
    func didUpdateAvatar() {
        guard
            let avatarUrlString = profileImageService.avatarURL,
            let avatarUrl = URL(string: avatarUrlString)
        else { return }
        viewInput?.updateAvatar(with: avatarUrl)
    }
    
    func didLogOutButtonTapped() {
        viewInput?.showLogOutAlert()
    }
    
    func cleanServices() {
        WebViewController.clean()
        OAuthTokenStorage.clean()
        ImagesListService.shared.clean()
        ProfileImageService.shared.clean()
        ProfileService.shared.clean()
    }
}
