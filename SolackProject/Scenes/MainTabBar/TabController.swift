//
//  TabController.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
final class TabController: UITabBarController {
    var disposeBag = DisposeBag()
    weak var nowVC: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .text
        setTabItems()
    }
}

extension TabController {
    
    private var tabViewControllers: [UIViewController] {
        let provider = AppManager.shared.provider
        let homeVC = HomeVC()
        homeVC.reactor = HomeReactor(provider)
        let dmMainVC = DMMainVC()
        dmMainVC.reactor = DMMainReactor(provider)
        let searchVC = ViewController()
        let settingsVC = ViewController()
        settingsVC.title = "Account"
        return [homeVC,dmMainVC,searchVC,settingsVC]
    }
    
    private var tabbarStrings: [TabbarString] {
        [
            TabbarString(title: "홈", defaultIcon: .home, selectedIcon: .homeActive),
            TabbarString(title: "DM", defaultIcon: .message, selectedIcon: .messageActive),
            TabbarString(title: "검색", defaultIcon: .search, selectedIcon: .searchActive),
            TabbarString(title: "설정", defaultIcon: .setting, selectedIcon: .settingActive)
        ]
    }
    
    func setTabItems() {
        let navigationViewControllers = zip(tabViewControllers, tabbarStrings).map {
            $0.0.navigationItem.largeTitleDisplayMode = .always
            let navigationController = UINavigationController(rootViewController: $0.0)
            navigationController.tabBarItem = $0.1.getTabbarItem()
            navigationController.navigationBar.prefersLargeTitles = true
            return navigationController
        }
        
        setViewControllers(navigationViewControllers, animated: false)
    }
}
extension TabController {
    struct TabbarString {
        let title: String?
        let defaultIcon: UIImage
        let selectedIcon: UIImage
        
        func getTabbarItem()-> UITabBarItem {
            UITabBarItem(title: title, image: defaultIcon, selectedImage: selectedIcon)
        }
    }
    
}
