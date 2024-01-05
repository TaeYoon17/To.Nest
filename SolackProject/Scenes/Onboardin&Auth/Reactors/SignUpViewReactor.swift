//
//  SignUpViewReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import Foundation
import ReactorKit
import RxSwift

enum SignUpToastType{
    case emailValidataionError
    case vailableEmail
    case alreadyAvailable
    var contents:String{
        switch self{
        case .emailValidataionError: "이메일 형식이 올바르지 않습니다."
        case .vailableEmail: "사용 가능한 이메일입니다."
        case .alreadyAvailable: "사용 가능한 이메일입니다."
        }
    }
}
class SignUpViewReactor: Reactor{
    var initialState: State = State()
    let provider: ServiceProviderProtocol
    var email = ""
    enum Action{
        case setEmail(String)
        case setNickname(String)
        case setPhone(String)
        case dobuleCheck
        case setSecret(String)
        case setCheckSecret(String)
    }
    enum Mutation{
        case setEmail(String)
        case setNickname(String)
        case setPhone(String)
        case doubleCheck(Bool)
        case setSecret(String)
        case setCheckSecret(String)
        case setSignUpToast(SignUpToastType?)
    }
    struct State{
        var email:String = ""
        var nickName:String = ""
        var secret:String = ""
        var checkSecret:String = ""
        var phone:String = ""
        var isEmailChecked:Bool = false
        var signUpToast:SignUpToastType? = nil
    }
    init(provider: ServiceProviderProtocol){
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .setEmail(let email):
            self.email = email
            return Observable.concat([
                .just(.setEmail(email)),
                .just(.doubleCheck(false))
            ])
        case .setNickname(let name):
            return Observable.concat([
                .just(.setNickname(name))
            ])
        case .setPhone(let phone):
            return Observable.concat([
                .just(.setPhone(phone))
            ])
        case .dobuleCheck:
            let check = NM.shared.emailCheck(email)
            let doubleCheck = check.map{Mutation.doubleCheck($0)}
            let toast = check.map{ Mutation.setSignUpToast($0 ? .vailableEmail : .emailValidataionError) }
            return Observable.concat([
                doubleCheck,
                toast.delay(.nanoseconds(100), scheduler: MainScheduler.instance),
                .just(.setSignUpToast(nil)).delay(.nanoseconds(100), scheduler: MainScheduler.instance)
            ])
        case .setSecret(let secret):
            return Observable.concat([
                .just(.setSecret(secret))
            ])
        case .setCheckSecret(let secret):
            return Observable.concat([
                .just(.setCheckSecret(secret))
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setEmail(let email):
            state.email = email
        case .setNickname(let nick):
            state.nickName = nick
        case .setPhone(let phone):
            state.phone = phone
        case .doubleCheck(let valiEmail):
            state.isEmailChecked = valiEmail
        case .setSecret(let secret):
            state.secret = secret
        case .setCheckSecret(let checkSecret):
            state.checkSecret = checkSecret
        case .setSignUpToast(let type):
            state.signUpToast = type
        }
        return state
    }
}
