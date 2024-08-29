//
//  OnboardingView+ASDelegate.swift
//  SolackProject
//
//  Created by 김태윤 on 1/15/24.
//

import UIKit
import SnapKit
import AuthenticationServices
extension OnboardingView:ASAuthorizationControllerPresentationContextProviding{
    // Sign in with Apple 버튼 클릭
    @objc func appleLoginButtonClicked(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // 로그인시 가져올 정보
        request.requestedScopes = [.email,.fullName]
        // 인증과 관련된 컨트롤러 생성
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        // 시스템이 사용자에게 인증 인터페이스를 표시할 수 있는 디스플레이 컨텍스트를 제공하는 델리게이트입니다.
        controller.presentationContextProvider = self
        // 요청 처리
        controller.performRequests()
    }
    // 애플 로그인 용 뷰 띄워주기
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
// iOS 13 이상 가능
extension OnboardingView: ASAuthorizationControllerDelegate{
    // 애플로 로그인 실패한 경우
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Login Failed \(error.localizedDescription)")
    }
    
    // 애플로 로그인 성공한 경우 -> 메인 페이지로 이동 등.. (사용자 성공, email, name -> 서버)
    // 처음 시도: 계속, Email, fullName 반환
    // 두번째 시도: 로그인할래요? Email, fullName nil값으로..
    // 사용자 정보를 계속 제공해주지 않는다. -> 최초에만 제공...
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        @DefaultsState(\.appleID) var appleID
        switch authorization.credential{
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print(appleIDCredential)
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            let token = appleIDCredential.identityToken
            
            guard let token = appleIDCredential.identityToken,
                  let tokenToString = String(data: token,encoding: .utf8) else{
                print("Token Error")
                return
            }
            
            
//            if email?.isEmpty ?? true{
//                let result = tokenToString.jwtTokenDecode()["email"] as? String ?? ""
//                print("email empty result, apple privacy email 반환")
//                print(result)
//            }
            // 이메일, 토큰, 이름 -> UserDefaults & API로 서버에 POST
            // 서버에 Request 후 Response를 받게 되면, 성공 시 화면 전환
            let formatter = PersonNameComponentsFormatter()
            let name = if let fullName{ formatter.string(from: fullName) }else { "" }
            let info = AppleInfo(idToken: tokenToString, nickName: name)
//            UserDefaults.standard.set(userIdentifier,forKey: "User")
            appleID = userIdentifier
            reactor?.provider.signService.appleSignIn(info)
//                res = try await NM.shared.signIn(type: .apple, body: info)
            //            Task{@MainActor in
            //                self.present(MainViewController(),animated: true)
            //            }
            // 키체인 관련 코드..? -> 아이클라우드 키 체인에서 접근, 애플 로그인과 큰 관련 없음
        case let passwordCredential as ASPasswordCredential:
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print(username,password)
        default:break
        }
    }
}
