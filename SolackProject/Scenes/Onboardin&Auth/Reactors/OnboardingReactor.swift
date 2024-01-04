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

class OnboardingViewReactor: Reactor {
    /// 초기 상태를 정의합니다.
    let initialState :State
    let provider: ServiceProviderProtocol
    
    enum Action {
        case auth
    }
    
    /// 처리 단위를 정의합니다.
    ///
    /// 액션을 받았을 때 변화
    enum Mutation {
        case requestSignIn(SignInType)
        case setLoading(Bool)
        case requestSignUp
        case authPresenting
    }
    
    /// 현재 상태를 기록합니다.
    ///
    /// 어떠한 변화를 받은 상태!
    struct State {
        var value = 0
        var isLoading = false
        var signInType: SignInType? = nil
        var signUp: Bool = false
        var isAuthPresent = false
    }
    
    init(){
        print("생성!!")
        self.provider = ServiceProvider()
        self.initialState = State()
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let eventMutation = provider.authService.event.flatMap { event -> Observable<Mutation> in
            print("넘기기 성공!!")
            return switch event{
            case .signIn(let signIn):
                Observable.concat([
                    .just(.setLoading(false)),
                    .just(.requestSignIn(signIn))
                ])
                
            case .signUp:
                Observable.concat([
                    .just(.setLoading(false)),
                    .just(.requestSignUp)
                ])
            case .updateAccessToken(let string):
                    .just(.requestSignUp)
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
        return Observable.merge(mutation, eventMutation,navigationMutation)
    }
    /// Action이 들어온 경우 어떤 처리를 할 것인지 분기
    ///
    /// Mutation에서 정의한 작업 단위들을 사용하여 Observable로 방출
    ///
    /// 액션에 맞게 행동해!
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .auth:
            return Observable.concat([
                Observable.just(.authPresenting).delay(.microseconds(100), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(true))
            ])
        }
    }
    /// 이전 상태와 처리 단위를 받아서 다음 상태를 반환하는 함수
    ///
    /// mutate(action: )이 실행되고 난 후 바로 해당 메소드를 실행
    ///
    /// 변화에 맞게끔 값을 설정해!
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
