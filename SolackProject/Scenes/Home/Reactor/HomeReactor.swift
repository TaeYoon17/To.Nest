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
    }
    enum Mutation{
        case channelDialog(HomePresent?)
    }
    struct State{
        var channelDialog:HomePresent? = nil
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
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .channelDialog(let present):
            state.channelDialog = present
        }
        return state
    }
}
