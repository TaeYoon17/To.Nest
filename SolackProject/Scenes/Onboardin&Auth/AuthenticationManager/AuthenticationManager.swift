//
//  AuthenticationManager.swift
//  AppleLogIn
//
//  Created by 김태윤 on 12/29/23.
//

import Foundation
import LocalAuthentication
// FaceID가 계속 실패할 때..! Fallback 처리가 필요하다.
// FaceID가 없으면?
// - 다른 인증 방법 혹은 FaceID 등록 (비밀번호만 있거나, 아예 잠그지 않는 사람)
// - FaceID 설정하려면 아이폰 암호가 먼저 설정되어야한다.
// - FaceID 변경 -> domainStateData (안경, 마스크 등은)
// - FaceID 결과는 메인쓰레드 보장 X -> MainActor 필요
// - 한 화면에서, FaceID 인증을 성공하면, 해당 화면에 대해서는 success
final class AuthenticationManager{
    static let shared = AuthenticationManager()
    private init(){}
    
//    var selectedPoilicy: LAPolicy = .deviceOwnerAuthentication // 생체 인증 및 암호
// 생체 인증시 사용
    var selectedPoilicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
    func auth(){
        let context = LAContext()
        context.localizedCancelTitle = "FaceID 인증 취소"
        context.localizedFallbackTitle = "비밀번호 대신 인증"
        context.evaluatePolicy(selectedPoilicy, localizedReason: "페이스 아이디 인증이 필요합니다.") { isSuccess, error in
            print(isSuccess)
            if let error{
                let code = error._code
                let laError = LAError(LAError.Code(rawValue: code)!)
                print(laError)
            }
        }
    }
    // FaceID 사용할 수 있는지 확인
    func checkPoilicy()->Bool{
        let context = LAContext()
        let policy: LAPolicy = selectedPoilicy
        return context.canEvaluatePolicy(policy, error:  nil)
    }
    // FaceID 정보 변경시
    func isFaceIDChanged() -> Bool{
        let context = LAContext()
        context.canEvaluatePolicy(selectedPoilicy, error: nil)
        let state = context.evaluatedPolicyDomainState // 생체 인증 정보
        
        // 생체 인증 정보를 UserDefaults에 저장한다.
        // 기존에 저장된 DomainState와 새롭게 변경된 DomainState를 비교 =>
        
        return false
    }
}
