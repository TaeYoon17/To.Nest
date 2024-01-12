//
//  SignUpViewReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import Foundation
import ReactorKit
import RxSwift
final class SignUpViewReactor: Reactor{
    var initialState: State = State()
    weak var provider: ServiceProviderProtocol!
    var info = SignUpInfo()
    var validedEmailCache = Set<String>()
    var emailValided = false
    var checkedPW = ""
    var networkDisposeBag = DisposeBag()
    enum Action{
        case setEmail(String)
        case setNickname(String)
        case setPhone(String)
        case dobuleCheck
        case setSecret(String)
        case setCheckSecret(String)
        case signUpCheck
    }
    enum Mutation{
        case setEmail(String)
        case setNickname(String)
        case setPhone(String)
        case setSecret(String)
        case setCheckSecret(String)
        case setSignUpToast(SignUpToastType?)
        case validationFailedTypes([SignUpFieldType])
    }
    struct State{
        var email:String = ""
        var nickName:String = ""
        var secret:String = ""
        var checkSecret:String = ""
        var phone:String = ""
        var isDoubleCheckAvailable:Bool = false
        var isSignUpAvailable = false
        var signUpToast:SignUpToastType? = nil
        var emailErrored:Bool = false
        var nickNameErrored:Bool = false
        var phoneErrored:Bool = false
        var pwErrored:Bool = false
    }
    init(provider: ServiceProviderProtocol){
        self.provider = provider
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
        case .setSecret(let secret):
            state.secret = secret
        case .setCheckSecret(let checkSecret):
            state.checkSecret = checkSecret
        case .setSignUpToast(let type):
            state.signUpToast = type
        case .validationFailedTypes(let types):
            state.emailErrored = false
            state.pwErrored = false
            state.phoneErrored = false
            state.nickNameErrored = false
            for type in types{
                switch type{
                case .email: state.emailErrored = true
                case .nickname: state.nickNameErrored = true
                case .phone: state.phoneErrored = true
                case .pw: state.pwErrored = true
                }
            }
        }
        return state
    }
    func transform(state: Observable<State>) -> Observable<State> {
        state.flatMap { st -> Observable<State> in
            var st = st
            st.isSignUpAvailable = !st.checkSecret.isEmpty && !st.nickName.isEmpty  && !st.secret.isEmpty && !st.email.isEmpty
            return .just(st)
        }
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let signMutation = provider.signService.event.flatMap { event -> Observable<Mutation> in
            switch event{
            case .failedSign(let failed):
                switch failed{
                case .signUpDoubled:
                    return Observable.just(.setSignUpToast(.alreadySignedUp))
                case .signUpwrong:
                    return .just(.setSignUpToast(.other))
                default:
                    return Observable.concat([])
                }
            case .successSign:
                AppManager.shared.userAccessable.onNext(true)
                return Observable.concat([])
            }
        }
        return Observable.merge(mutation,signMutation)
    }
}

