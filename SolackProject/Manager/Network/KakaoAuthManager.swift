//
//  KakaoManager.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import RxSwift
import RxKakaoSDKAuth
import KakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKUser
final class KakaoManager{
    static let shared = KakaoManager()
    var disposeBag = DisposeBag()
    // 회원 가입 및 로그인을 위한 토큰 값 얻어오기
    @MainActor func getKakaoToken() async throws -> String {
        let apiShared = UserApi.shared
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            let handler:(OAuthToken?,Error?) -> Void = {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    if let accessToken = oauthToken?.accessToken{
                        continuation.resume(returning: accessToken)
                        return
                    }else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                }
            }
            if (UserApi.isKakaoTalkLoginAvailable()){
                apiShared.loginWithKakaoTalk( completion: handler)
            }else{
                apiShared.loginWithKakaoAccount(completion:handler)
            }
        }
    }
}
