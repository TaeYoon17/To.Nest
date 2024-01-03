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

class CounterViewReactor: Reactor {
    /// 초기 상태를 정의합니다.
    let initialState = State()
    
    /// 사용자 행동을 정의합니다.
    ///
    /// 사용자에게 받을 액션
    enum Action {
        case increase
        case decrease
    }
    
    /// 처리 단위를 정의합니다.
    ///
    /// 액션을 받았을 때 변화
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
    }
    
    /// 현재 상태를 기록합니다.
    ///
    /// 어떠한 변화를 받은 상태!
    struct State {
        var value = 0
        var isLoading = false
    }
    
    /// Action이 들어온 경우 어떤 처리를 할 것인지 분기
    ///
    /// Mutation에서 정의한 작업 단위들을 사용하여 Observable로 방출
    ///
    /// 액션에 맞게 행동해!
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .increase:
            return Observable.concat([ // concat은 평등하게 먼저 들어온 옵저버블을 순서대로 방출
                Observable.just(.setLoading(true)),
                Observable.just(.increaseValue).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(false))
            ])
        case .decrease:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                Observable.just(.decreaseValue).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(.setLoading(false))
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
        case .increaseValue:
            newState.value += 1
        case .decreaseValue:
            newState.value -= 1
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
}
enum SignInType{
    case apple
    case kakao
    case email
}
class AccountReactor: Reactor{
    var initialState: State = State()
    
    
    enum Action{
        case appleSignIn
        case kakaoSignIn
        case emailSignIn
        case signUp
    }
    enum Mutation{
        case authorizing(Bool) // 회원 가입 진행 중, 혹은 다른 곳 로그인 중
        case complete(String) // 무엇이든지 종료, 액세스 토큰 반환
    }
    struct State{
        var type: SignInType? = nil
        var isLoading = false
        var accessToken = ""
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
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .authorizing(let value):
            state.isLoading = value
        case .complete(let str):
            state.accessToken = ""
        }
        return state
    }
//    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
//        
//    }
}
