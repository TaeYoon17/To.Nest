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
            switch event{
            case .homeWS(let wsResponse):
                var arr:[Observable<Mutation>] = []
                guard let members = wsResponse?.workspaceMembers else {return Observable.concat([])}
                if let profileImage = wsResponse?.thumbnail{
                    print(profileImage)
                    arr.append(.just(.setWSThumbnail(profileImage)).delay(.microseconds(100), scheduler: MainScheduler.instance))
                }
                arr.append(.just(.setMembsers(members)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance))
                return Observable.concat(arr)
            case .members(let response):
                return Observable.concat([
                    .just(.setMembsers(response)).debounce(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                ])
            default: return Observable.concat([])
            }
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
