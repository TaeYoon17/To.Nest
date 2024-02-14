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
    func appleSignIn(_ info: AppleInfo)
    func signUp(_ info:SignUpInfo)
    func signOut()
}
final class SignService: SignServiceProtocol{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.expiration) var expiration
    @DefaultsState(\.myProfile) var myProfile
    @DefaultsState(\.myInfo) var myInfo
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
                await defaultsSign(response)
                AppManager.shared.userAccessable.onNext(true)
                event.onNext(.successSign)
            }catch let failed where failed is SignFailed{
                event.onNext(.failedSign(failed as! SignFailed))
            }catch let fail where fail is Errors.API{
                event.onNext(.failedSign(.signInFailed))
            }catch{
                print("Email SignIn Error \(error)")
            }
        }
    }
    func appleSignIn(_ info: AppleInfo){
        Task{
            do{
                let resposne = try await NM.shared.signIn(type: .apple, body: info)
                await defaultsSign(resposne)
                AppManager.shared.userAccessable.onNext(true)
                event.onNext(.successSign)
            }catch let failed where failed is SignFailed{
                event.onNext(.failedSign(failed as! SignFailed))
            }catch let fail where fail is Errors.API{
                event.onNext(.failedSign(.signInFailed))
            }catch{
                print("Apple SignIn Error \(error)")
            }
        }
    }
    func kakaoSignIn(){
        Task{
            do {
                let kakaoToken = try await KakaoManager.shared.getKakaoToken()
                let signResponse = try await NM.shared.signIn(type: .kakao, body: KakaoInfo(oauthToken: kakaoToken))
                await defaultsSign(signResponse)
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
                await defaultsSign(response)
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
    fileprivate func defaultsSign(_ response: SignResponse)async {
        accessToken = response.token.accessToken
        refreshToken = response.token.refreshToken
        expiration = Date(timeIntervalSinceNow: NetworkManager.accessExpireSeconds)
        let myInfo = MyInfo.getBySignResponse(response)
        Task{@MainActor in
            self.myInfo = myInfo
        }
        print("사인 myInfo \(myInfo)")
        self.userID = myInfo.userID
            if let webImageURL = response.profileImage{
                let data = await NM.shared.getThumbnail(webImageURL)
                self.myProfile = data
            }
    }
}
extension MyInfo{
    static func getBySignResponse(_ res: SignResponse) -> MyInfo {
        Self.init(userID: res.userID,
                  email: res.email,
                  nickname: res.nickname,
                  profileImage: res.profileImage,
                  phone: res.phone,
                  vendor: res.vendor,
                  createdAt: res.createdAt)
    }
}
