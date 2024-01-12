//
//  EmailSignInReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
import ReactorKit
import RxSwift
enum EmailSignInFieldType{
    case email
    case password
}
final class EmailSignInReactor: Reactor{
    var initialState = State()
    var info = EmailInfo()
    weak var provider: ServiceProviderProtocol!
    enum Action{
        case setEmail(String)
        case setPassword(String)
        case signIn
    }
    enum Mutation{
        case setEmail(String)
        case setPassword(String)
        case setToast(EmailSignInToastType?)
        case setErrorField([EmailSignInFieldType])
    }
    struct State{
        var email:String = ""
        var password:String = ""
        var toastMessage:EmailSignInToastType? = nil
        var signAvailable = false
        var erroredEmail = false
        var erroredPW = false
    }
    init(provider: ServiceProviderProtocol){
        self.provider = provider
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setEmail(let email):
            state.email = email
        case .setPassword(let pw):
            state.password = pw
        case .setToast(let toast):
            state.toastMessage = toast
        case .setErrorField(let types):
            state.erroredEmail = false
            state.erroredPW = false
            for type in types {
                switch type{
                case .email: state.erroredEmail = true
                case .password: state.erroredPW = true
                }
            }
        }
        return state
    }
    func transform(state: Observable<State>) -> Observable<State> {
        state.flatMap { state -> Observable<State> in
            var st = state
            st.signAvailable = !st.email.isEmpty && !st.password.isEmpty
            return .just(st)
        }
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let signIn = provider.signService.event.flatMap { event -> Observable<Mutation> in
            switch event{
            case .failedSign(let errorType):
                switch errorType{
                case .signInFailed:
                    return Observable.concat([
                        .just(.setToast(.signInFailed)).delay(.nanoseconds(100), scheduler: MainScheduler.asyncInstance),
                        .just(.setToast(nil))
                    ])
                default:
                    return Observable.concat([
                        .just(.setToast(.other)).delay(.nanoseconds(100), scheduler: MainScheduler.asyncInstance),
                        .just(.setToast(nil))
                    ])
                }
                
            case .successSign:
                AppManager.shared.userAccessable.onNext(true)
                return Observable.concat([])
            }
        }
        return Observable.merge([mutation,signIn])
    }
}
