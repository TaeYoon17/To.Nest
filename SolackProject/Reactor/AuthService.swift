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
    func updateAccessToken(_ token:String)  -> Observable<String>
}
class AuthService: AuthServiceProtocol{
    let event = PublishSubject<Event>()
    enum Event{
        case updateAccessToken(String)
    }
    func updateAccessToken(_ token:String)  -> Observable<String>{
        event.onNext(.updateAccessToken(token))
        return .just(token)
    }
}
