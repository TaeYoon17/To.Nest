//
//  OnboardingReactor.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

final class OnboardingViewReactor: Reactor {
    /// 초기 상태를 정의합니다.
    let initialState :State
    weak var provider: ServiceProviderProtocol!
    
    enum Action {
        case auth
        case signInWithKakaoTalk
    }
    enum Mutation {
        case requestSignIn(SignInType)
        case setLoading(Bool)
        case requestSignUp
        case authPresenting
    }
    struct State {
        var value = 0
        var isLoading = false
        var signInType: SignInType? = nil
        var signUp: Bool = false
        var isAuthPresent = false
    }
    
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
        self.initialState = State()
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let eventMutation = provider.authService.event.flatMap {[weak self] event -> Observable<Mutation> in
            switch event{
            case .signIn(let signIn):
                return Observable.concat([
                    .just(.setLoading(false)),
                    .just(.requestSignIn(signIn))
                ])
            case .signUp:
                return Observable.concat([
                    .just(.setLoading(false)),
                    .just(.requestSignUp)
                ])
            case .updateAccessToken(let string):
                return .just(.requestSignUp)
            }
        }
        let navigationMutation = provider.authService.navigation.flatMap { event -> Observable<Mutation> in
            switch event{
            case .dismissCompleted:
                Observable.concat([
                    .just(.setLoading(true))
                ])
            }
        }
        let signInMutation = provider.signService.event.flatMap { event -> Observable<Mutation> in
            switch event{
            case .successSign:
                return Observable.concat([])
            case .failedSign(let failed):
                return Observable.concat([])
            }
        }
        return Observable.merge(mutation, eventMutation,navigationMutation,signInMutation)
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .auth:
            return Observable.concat([
                Observable.just(.authPresenting).delay(.microseconds(100), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(true))
            ])
        case .signInWithKakaoTalk:
            provider.signService.kakaoSignIn()
            return Observable.concat([
                
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .requestSignIn(let sign):
            newState.signInType = sign
            newState.signUp = false
            newState.isAuthPresent = false
        case .requestSignUp:
            newState.signUp = true
            newState.signInType = nil
            newState.isAuthPresent = false
        case .authPresenting:
            newState.isAuthPresent = true
            newState.signUp = false
            newState.signInType = nil
        default: break
        }
        return newState
    }
    
    func reactorForAuth() -> AuthViewReactor {
        return AuthViewReactor(provider: provider)
    }
}
