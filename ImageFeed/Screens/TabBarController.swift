import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let tabBarApperance = UITabBarAppearance()
        tabBarApperance.configureWithOpaqueBackground()
        tabBarApperance.backgroundColor = .customBlack
        UITabBar.appearance().standardAppearance = tabBarApperance
    
        tabBar.tintColor = .white
        tabBar.backgroundColor = .customBlack
        
        let dataSource: [Tabs] = [.imagesList, .profile]
        
        viewControllers = dataSource.map {
            switch $0 {
            case .imagesList:
                return UINavigationController(rootViewController: ImagesListViewController())
            case .profile:
                let profileViewController = ModuleBuilder.shared.makeProfileModule()
                return profileViewController
            }
        }
        
        viewControllers?.enumerated().forEach {
            $1.tabBarItem.title = nil
            $1.tabBarItem.image = UIImage(named: dataSource[$0].iconName)
            $1.tabBarItem.tag = $0
        }
    }
}

enum Tabs: Int {
    case imagesList
    case profile
    
    var iconName: String {
        switch self {
        case .imagesList:
            return "TabEditorialActive"
        case .profile:
            return "TabProfileActive"
        }
    }
}

