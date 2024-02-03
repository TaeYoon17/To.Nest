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
    enum Action{
        case initAction
    }
    enum Mutation{
        
    }
    struct State{
        
    }
    func mutate(action: Action) -> Observable<Mutation> {
        return Observable.concat([])
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        return state
    }
}
