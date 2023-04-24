import Foundation

final class ProfilePresenter {
    weak var viewInput: ProfileViewInput?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    
    init(profileService: ProfileService, profileImageService: ProfileImageService) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
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
