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
import iamport_ios
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var disposeBag = DisposeBag()
    @DefaultsState(\.expiration) var expiration
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.appleID) var appleID
    @DefaultsState(\.mainWS) var mainWS
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        AppManager.shared.initNavigationAppearances()
        RxKakaoSDK.initSDK(appKey: Kakao.nativeKey)
        userAccessConnect()
        firstAccessConnect()
        print("-------accessToken-------")
        print(accessToken)
        Task{
            do{
                let repository = try await TableRepository()
                await repository.checkPath()
            }catch{
                fatalError("리포지토리 생성 오류 \(error)")
            }
        }
        accessByAppleSignIn()
    }
    //MARK: -- 애플로그인 접근 결과를 보여주는 것
    func accessByAppleSignIn(){
        guard let appleID else {return}
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: appleID) {[weak self] credintialState, error in
            guard let self else {return}
            print("* getCredintailState 발생")
            switch credintialState{
            case .revoked:
                print("Revoked")
            case .authorized:
                print("Authorized")
            default: print("NOT FOUND")
            }
        }
    }
    //MARK: -- 카카오 웹 페이지 로그인 결과
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
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    //MARK: -- 앱이 다시 foreground로 돌아올 때
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("변화가 일어난다!!")
// MARK: -- 프로필 업데이트 시점... 계정 변환 고려사항으로 인해 잠시 작동 멈춤
//        AppManager.shared.provider.chService.checkAllMy()
//        AppManager.shared.provider.dmService.checkAll(wsID: mainWS.id)
//        AppManager.shared.provider.wsService.checkAllMembers()
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


extension RxKakaoSDK{
    
}
