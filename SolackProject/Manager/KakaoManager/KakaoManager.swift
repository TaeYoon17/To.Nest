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
    func startLogIn(){
        print(#function,UserApi.isKakaoTalkLoginAvailable())
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.rx.loginWithKakaoTalk()
                .subscribe(onNext:{ (oauthToken) in
                    print("loginWithKakaoTalk() success.")
                
                    //do something
                    let kakaoToken = oauthToken
                    print("kaakoToken")
                    print(kakaoToken)
                }, onError: {error in
                    print("Error occured!!")
                    print(error)
                })
            .disposed(by: disposeBag)
        }
        
    }
}
