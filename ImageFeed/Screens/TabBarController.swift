import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let navControllerViewController = storyboard.instantiateViewController(
            withIdentifier: "NavControllerImagesListViewController"
        )
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "TabProfileActive"),
            selectedImage: nil
        )
        self.viewControllers = [navControllerViewController, profileViewController]
    }
}
