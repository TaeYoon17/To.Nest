//
//  WSManagerReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import Foundation
import ReactorKit
final class WSManagerReactor: Reactor{
    let initialState: State = .init()
    let provider: ServiceProviderProtocol
    enum Action{
        case close
    }
    enum Mutataion{
        case close(Bool)
    }
    struct State{
        var close = false
    }
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutataion> {
        switch action{
        case .close:
            Observable.just(Mutataion.close(true))
        }
    }
    func reduce(state: State, mutation: Mutataion) -> State {
        var st = state
        switch mutation{
        case .close(let close):
            st.close = close
        }
        return st
    }
}
