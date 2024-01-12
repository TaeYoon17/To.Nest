//
//  AuthPresentReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import Foundation
import RxSwift
import ReactorKit
enum SignInType{
    case apple
    case kakao
    case email
}
final class AuthViewReactor: Reactor{
    var initialState: State = State()
    weak var provider: ServiceProviderProtocol!
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
        var shouldDimsiss = false
    }
    
    init(provider: ServiceProviderProtocol){
        print("AuthViewReactor 생성!!")
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .appleSignIn:
            return Observable.concat([
                provider.authService.requestSignIn(.apple).map{ _ in .dismiss}
            ])
        case .emailSignIn:
            return Observable.concat([
                provider.authService.requestSignIn(.email).map{ _ in .dismiss}
            ])
        case .kakaoSignIn:
            return Observable.concat([
                provider.authService.requestSignIn(.kakao).map{ _ in .dismiss}
            ])
        case .signUp:
            return Observable.concat([
                provider.authService.requestSignUp().map{_ in .dismiss}
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
            print("dismiss 시작")
            state.shouldDimsiss = true
        }
        return state
    }
}
