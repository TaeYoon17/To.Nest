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
final class TabController: UITabBarController{
    var disposeBag = DisposeBag()
    weak var nowVC: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .text
        setTabItems()
    }
}
extension TabController{
    func setTabItems(){        
        let vc1 = HomeVC()
        vc1.title = "Today"
        let vc2 = ViewController()
        let vc3 = ViewController()
        let vc4 = ViewController()
        vc4.title = "Account"
        let naviControllers = zip([vc1,vc2,vc3,vc4],
                                  [TabbarString(title: "홈", defaultIcon: .home, selectedIcon: .homeActive),
                                   TabbarString(title: "DM", defaultIcon: .message, selectedIcon: .messageActive),
                                   TabbarString(title: "검색", defaultIcon: .search, selectedIcon: .searchActive),
                                   TabbarString(title: "설정", defaultIcon: .setting, selectedIcon: .settingActive)
                                  ]).map{
            $0.0.navigationItem.largeTitleDisplayMode = .always
            let nav = UINavigationController(rootViewController: $0.0)
            nav.tabBarItem = $0.1.getTabbarItem()
            nav.navigationBar.prefersLargeTitles = true
            return nav
        }
        setViewControllers(naviControllers, animated: false)
    }
}
extension TabController{
    struct TabbarString{
        let title: String?
        let defaultIcon: UIImage
        let selectedIcon: UIImage
        func getTabbarItem()-> UITabBarItem{
            UITabBarItem(title: title, image: defaultIcon, selectedImage: selectedIcon)
        }
    }
}
