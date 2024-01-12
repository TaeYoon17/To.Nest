//
//  EmailSignInService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
import RxSwift
protocol SignServiceProtocol{
    var event: PublishSubject<SignService.Event> {get}
    func emailSignIn(_ info:EmailInfo)
    func kakaoSignIn()
    func signUp(_ info:SignUpInfo)
}
final class SignService: SignServiceProtocol{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.nickname) var nickname
    @DefaultsState(\.phoneNumber) var phoneNumber
    @DefaultsState(\.profile) var profile
    @DefaultsState(\.email) var email
    @DefaultsState(\.expiration) var expiration
    @DefaultsState(\.userID) var userID
    let event = PublishSubject<Event>()
    enum Event{
        case successSign
        case failedSign(SignFailed)
    }
    func emailSignIn(_ info:EmailInfo){
        Task{
            do{
                let response = try await NM.shared.signIn(type: .email, body: info)
                // MARK: -- 여기 수정해야함
//                profile = response.profileImage
                defaultsSign(response)
                event.onNext(.successSign)
            }catch let failed where failed is SignFailed{
                event.onNext(.failedSign(failed as! SignFailed))
            }catch let fail where fail is Errors.API{
                event.onNext(.failedSign(.signInFailed))
            }
        }
    }
    func kakaoSignIn(){
        Task{
            do {
                let kakaoToken = try await KakaoManager.shared.getKakaoToken()
                let signResponse = try await NM.shared.signIn(type: .kakao, body: KakaoInfo(oauthToken: kakaoToken))
                defaultsSign(signResponse)
                AppManager.shared.userAccessable.onNext(true)
            }catch{
                print("error here:")
                print(error)
            }
        }
    }
    func signUp(_ info:SignUpInfo){
        Task{
            do{
                let response = try await NM.shared.signUp(info)
                defaultsSign(response)
                event.onNext(.successSign)
            }catch let failed where failed is SignFailed{
                event.onNext(.failedSign(failed as! SignFailed))
            }catch{
                event.onNext(.failedSign(.signUpwrong))
            }
        }
    }
}
extension SignService{
    fileprivate func defaultsSign(_ response: SignResponse){
        accessToken = response.token.accessToken
        refreshToken = response.token.refreshToken
        nickname = response.nickname
        phoneNumber = response.phone
        email = response.email
        expiration = Date(timeIntervalSince1970: NetworkManager.accessExpireSeconds)
        userID = response.userID
    }
}
