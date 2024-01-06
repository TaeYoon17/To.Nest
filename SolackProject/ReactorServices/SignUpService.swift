//
//  SignUpService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
import RxSwift
protocol SignUpServiceProtocol{
    var event: PublishSubject<SignUpService.Event> {get}
    func signUp(_ info:SignUpInfo)
}
final class SignUpService: SignUpServiceProtocol{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.nickname) var nickname
    @DefaultsState(\.phoneNumber) var phoneNumber
    @DefaultsState(\.profile) var profile
    @DefaultsState(\.email) var email
    let event = PublishSubject<Event>()
//    let navigation: PublishSubject<Navigation> = .init()
    enum Event{
        case successSignUp
        case failedSignUp(SignUpFailed)
    }
    func signUp(_ info:SignUpInfo){
        Task{
            do{
                let response = try await NM.shared.signUp(info)
                accessToken = response.token.accessToken
                refreshToken = response.token.refreshToken
                nickname = response.nickname
                phoneNumber = response.phone
                profile = response.profileImage
                email = response.email
                event.onNext(.successSignUp)
            }catch let failed where failed is SignUpFailed{
                event.onNext(.failedSignUp(failed as! SignUpFailed))
            }
        }
    }
}
