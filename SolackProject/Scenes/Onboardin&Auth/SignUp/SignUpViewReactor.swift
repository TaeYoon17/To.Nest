//
//  SignUpViewReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import Foundation
import ReactorKit
import RxSwift
class SignUpViewReactor: Reactor{
    var initialState: State = State()
    let provider: ServiceProviderProtocol
    enum Action{
        case cancel
        case appleSignIn
        case kakaoSignIn
        case emailSignIn
        case signUp
    }
    enum Mutation{
        case authorizing(Bool) // 회원 가입 진행 중, 혹은 다른 곳 로그인 중
        case complete(String) // 무엇이든지 종료, 액세스 토큰 반환
        case dismiss
    }
    struct State{
        var type: SignInType? = nil
        var isLoading = false
        var accessToken = ""
        var isSignUpAble = false
    }
    init(provider: ServiceProviderProtocol){
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .appleSignIn:
            return Observable.concat([
                Observable.just(.authorizing(true)),
                Observable.just(.authorizing(false)),
            ])
        case .emailSignIn:
            return Observable.concat([
                Observable.just(.authorizing(true)),
                Observable.just(.authorizing(false)),
            ])
        case .kakaoSignIn:
            return Observable.concat([
                Observable.just(.authorizing(true)),
                Observable.just(.authorizing(false)),
            ])
        case .signUp:
            return Observable.concat([
                Observable.just(.authorizing(true)),
                Observable.just(.authorizing(false)),
            ])
        case .cancel:
            return Observable.concat([
                Observable.just(.authorizing(false))
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .authorizing(let value):
            state.isLoading = value
        case .complete(let str):
            state.accessToken = ""
        case .dismiss:
            state.isLoading = false
        }
        return state
    }
    //    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    //
    //    }
}
