//
//  HomeReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
enum HomePresent{
    case create
    case explore
}
final class HomeReactor: Reactor{
    let initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    enum Action{
        case setPresent(HomePresent?)
        case setMainWS(wsID:String)
        case initMainWS
    }
    enum Mutation{
        case channelDialog(HomePresent?)
        case isEmptyWS(Bool)
    }
    struct State{
        var channelDialog:HomePresent? = nil
        var isEmptyWS: Bool? = nil
    }
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .setPresent(let present):
            return Observable.concat([
                Observable.just(.channelDialog(present)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                Observable.just(.channelDialog(nil)).delay(.milliseconds(100), scheduler: MainScheduler.instance)
            ])
        case .setMainWS(wsID: let wsID):
            provider.wsService.setHomeWS(wsID: Int(wsID)!)
            return Observable.concat([])
        case .initMainWS:
            provider.wsService.initHome()
            return Observable.concat([])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .channelDialog(let present):
            state.channelDialog = present
        case .isEmptyWS(let isEmpty):
            state.isEmptyWS = isEmpty
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let res = provider.wsService.event.flatMap { event -> Observable<Mutation> in
            switch event{
            case .checkAll(let response):
                return Observable.concat([.just(.isEmptyWS(response.isEmpty))])
            default: return Observable.concat([])
            }
        }
        return Observable.merge(mutation,res)
    }
}
