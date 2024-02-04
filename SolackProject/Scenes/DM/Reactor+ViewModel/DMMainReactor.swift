//
//  DMMainReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import ReactorKit
import RxSwift

final class DMMainReactor: Reactor{
    var initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
    }
    enum Action{
        case initAction
    }
    enum Mutation{
        case setMembsers([UserResponse])
        case setWSThumbnail(String)
    }
    struct State{
        var membsers:[UserResponse] = []
        var wsThumbnail:String = ""
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initAction:
            provider.wsService
            return Observable.concat([])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let wsMutation = provider.wsService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .homeWS(let wsResponse):
                guard let members = wsResponse?.workspaceMembers else {return Observable.concat([])}
                return Observable.concat([
                    .just(.setMembsers(members)).debounce(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                ])
            case .members(let response):
                return Observable.concat([
                    .just(.setMembsers(response)).debounce(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                ])
            default: return Observable.concat([])
            }
        }
        return Observable.merge([mutation,wsMutation])
    }
}
