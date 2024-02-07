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
        case appendMembers([UserResponse])
        case setWSThumbnail(String)
        case isProfileUpdated(Bool)
    }
    struct State{
        var membsers:[UserResponse] = []
        var wsThumbnail:String = ""
        var isProfileUpdated = false
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initAction:
            return Observable.concat([])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setMembsers(let members):
            state.membsers = members
        case .appendMembers(let members):
            state.membsers.append(contentsOf: members)
        case .setWSThumbnail(let thumbnail):
            state.wsThumbnail = thumbnail
        case .isProfileUpdated(let updated):
            state.isProfileUpdated = updated
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let wsMutation = provider.wsService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            var mutList:[Observable<Mutation>] = []
            switch event{
            case .homeWS(let wsResponse):
                guard let members = wsResponse?.workspaceMembers else {return Observable.concat([])}
                if let profileImage = wsResponse?.thumbnail{
                    mutList.append(.just(.setWSThumbnail(profileImage)).delay(.microseconds(100), scheduler: MainScheduler.instance))
                }
                mutList.append(.just(.setMembsers(members)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance))
            case .members(let response):
                mutList.append(
                    .just(.setMembsers(response)).debounce(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                )
            case .invited(let response):
                if !currentState.membsers.contains(response){
                    mutList.append(
                        .just(.appendMembers([response])).debounce(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                    )
                }
            default: break
            }
            return Observable.concat(mutList)
        }
        let profileMutation = provider.profileService.event.flatMap { event -> Observable<Mutation> in
            switch event{
            case .updatedImage:
                return Observable.concat([
                    .just(Mutation.isProfileUpdated(true)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                   .just(Mutation.isProfileUpdated(false))
              ])
            default: return Observable.concat([])
            }
        }
        return Observable.merge([mutation,wsMutation,profileMutation])
    }
}
