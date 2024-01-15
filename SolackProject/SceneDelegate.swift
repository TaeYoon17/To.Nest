//
//  SceneDelegate.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import UIKit
import RxKakaoSDKCommon
import RxKakaoSDKAuth
import KakaoSDKAuth
import RxSwift
import AuthenticationServices
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var disposeBag = DisposeBag()
    @DefaultsState(\.expiration) var expiration
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.appleID) var appleID
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        RxKakaoSDK.initSDK(appKey: Kakao.nativeKey)
        userAccessConnect()
//        accessByAppleSignIn()
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
    func accessByAppleSignIn(){
        guard let appleID else {return}
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: appleID) {[weak self] credintialState, error in
            guard let self else {return}
            switch credintialState{
            case .revoked:
                print("Revoked")
            case .authorized:
                print("Authorized")
                Task{
                    await MainActor.run {
                        print("여기 허가됨...")
//                        window?.rootViewController = MainViewController()
//                        self.window = window
//                        window.makeKeyAndVisible()
                    }
                }
            default: print("NOT FOUND")
            }
        }
    }
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                let val: Bool = AuthController.rx.handleOpenUrl(url: url)
                if val{
                    print("Success to get kakao Token")
                }else{
                    print("Failed to get kakao Token")
                }
            }
        }
    }
    func userAccessConnect(){
        AppManager.shared.userAccessable.debounce(.nanoseconds(100), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, isLogIn in
            guard let view = owner.window?.rootViewController?.view else {
                print("여기서 문제가 발생함!!")
                return
            }
            print("userAccessConnect 발생한다")
            let vc: UIViewController
            if isLogIn{
                vc = TabController()
            }else{
                let onboardvc = OnboardingView()
                let reactor = OnboardingViewReactor(AppManager.shared.provider)
                onboardvc.reactor = reactor
                vc = onboardvc
            }
            let coverView = UIView()
            coverView.backgroundColor = .gray1
            vc.view.addSubview(coverView)
            coverView.frame = vc.view.bounds
            owner.window?.rootViewController = vc
            owner.window?.makeKeyAndVisible()
            UIView.animate(withDuration: 0.5) {
                coverView.alpha = 0
            }completion: { _ in
                coverView.removeFromSuperview()
            }
        }.disposed(by: disposeBag)
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

