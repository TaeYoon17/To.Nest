//
//  AuthService.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import Foundation
import RxSwift
protocol AuthServiceProtocol{
    var event: PublishSubject<AuthService.Event> {get}
    var navigation: PublishSubject<AuthService.Navigation> {get}
    func updateAccessToken(_ token:String)  -> Observable<String>
    func requestSignIn(_ type: SignInType) -> Observable<SignInType>
    func requestSignUp() -> Observable<Void>
}
final class AuthService: AuthServiceProtocol{
    let event = PublishSubject<Event>()
    let navigation: PublishSubject<Navigation> = .init()
    enum Event{
        case updateAccessToken(String)
        case signIn(SignInType)
        case signUp
    }
    enum Navigation{
        case dismissCompleted
    }
    func requestSignIn(_ type: SignInType) -> Observable<SignInType>{
        event.onNext(.signIn(type))
        return .just(type)
    }
    func requestSignUp() -> Observable<Void>{
        event.onNext(.signUp)
        return .just(())
    }
    func updateAccessToken(_ token:String)  -> Observable<String>{
        event.onNext(.updateAccessToken(token))
        return .just(token)
    }
    func updateDeviceToken(){
        
    }
}
