//
//  EmailSignInService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
import RxSwift
protocol SignInServiceProtocol{
    var event: PublishSubject<SignInService.Event> {get}
    func emailSignIn(_ info:EmailInfo)
    func kakaoSignIn()
}
final class SignInService: SignInServiceProtocol{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.nickname) var nickname
    @DefaultsState(\.phoneNumber) var phoneNumber
    @DefaultsState(\.profile) var profile
    @DefaultsState(\.email) var email
    let event = PublishSubject<Event>()
    enum Event{
        case successSignIn
        case failedSignIn(SignFailed)
    }
    func emailSignIn(_ info:EmailInfo){
        Task{
            do{
                let response = try await NM.shared.signIn(type: .email, body: info)
                // MARK: -- 여기 수정해야함
//                profile = response.profileImage
                defaultsSignIn(response)
                event.onNext(.successSignIn)
            }catch let failed where failed is SignFailed{
                event.onNext(.failedSignIn(failed as! SignFailed))
            }catch let fail where fail is Errors.API{
                event.onNext(.failedSignIn(.signInFailed))
            }
        }
    }
    func kakaoSignIn(){
        Task{
            do {
                let kakaoToken = try await KakaoManager.shared.getKakaoToken()
                let signResponse = try await NM.shared.signIn(type: .kakao, body: KakaoInfo(oauthToken: kakaoToken))
                defaultsSignIn(signResponse)
                AppManager.shared.userAccessable.onNext(true)
            }catch{
                print("error here:")
                print(error)
            }
        }
    }
}
extension SignInService{
    fileprivate func defaultsSignIn(_ response: SignResponse){
        accessToken = response.token.accessToken
        refreshToken = response.token.refreshToken
        nickname = response.nickname
        phoneNumber = response.phone
        email = response.email
    }
}
//
//  EmailSignInService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
import RxSwift
protocol SignInServiceProtocol{
    var event: PublishSubject<SignInService.Event> {get}
    func emailSignIn(_ info:EmailInfo)
}
final class SignInService: SignInServiceProtocol{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.nickname) var nickname
    @DefaultsState(\.phoneNumber) var phoneNumber
    @DefaultsState(\.profile) var profile
    @DefaultsState(\.email) var email
    let event = PublishSubject<Event>()
    enum Event{
        case successSignIn
        case failedSignIn(SignFailed)
    }
    func emailSignIn(_ info:EmailInfo){
        Task{
            do{
                let response = try await NM.shared.signIn(type: .email, body: info)
                accessToken = response.token.accessToken
                refreshToken = response.token.refreshToken
                nickname = response.nickname
                phoneNumber = response.phone
                profile = response.profileImage
                email = response.email
                event.onNext(.successSignIn)
            }catch let failed where failed is SignFailed{
                event.onNext(.failedSignIn(failed as! SignFailed))
            }catch let fail where fail is Errors.API{
                event.onNext(.failedSignIn(.signInFailed))
            }
        }
    }
}
