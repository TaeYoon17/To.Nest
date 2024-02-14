//
//  SceneDelegate+AccessConnect.swift
//  SolackProject
//
//  Created by 김태윤 on 2/14/24.
//

import UIKit
import RxSwift
extension SceneDelegate{
    @MainActor func userAccessConnect(){
        AppManager.shared.userAccessable
            .debounce(.nanoseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, isLogIn in
            guard let view = owner.window?.rootViewController?.view else {
                fatalError("윈도우에 root view가 존재하지 않는다!!")
            }
            let vc: UIViewController
            if isLogIn{ vc = TabController()
            }else{
                let onboardvc = OnboardingView()
                let reactor = OnboardingViewReactor(AppManager.shared.provider)
                onboardvc.reactor = reactor
                vc = onboardvc
            }
//            let coverView = UIView()
//            coverView.backgroundColor = .gray1
//            vc.view.addSubview(coverView)
//            coverView.frame = vc.view.bounds
            owner.window?.rootViewController = vc
            owner.window?.makeKeyAndVisible()
            vc.coverAction()
//            UIView.animate(withDuration: 0.5) {
//                coverView.alpha = 0
//            }completion: { _ in
//                coverView.removeFromSuperview()
//            }
        }.disposed(by: disposeBag)
    }
    func firstAccessConnect(){
        if accessToken.isEmpty{
            let reactor = OnboardingViewReactor(AppManager.shared.provider)
            let vc = OnboardingView()
            vc.reactor = reactor
            window?.rootViewController = vc
        }else{
            window?.rootViewController = TabController()
        }
        window?.makeKeyAndVisible()
    }
}
