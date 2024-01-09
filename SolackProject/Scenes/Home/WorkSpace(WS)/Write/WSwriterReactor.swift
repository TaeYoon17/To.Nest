//
//  WSwriterReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import RxSwift
import ReactorKit
class WSwriterReactor:Reactor{
    var initialState = State()
    enum Action{
        case setName(String)
        case setDescription(String)
        case create
    }
    enum Mutation{
        case setName(String)
        case setDescription(String)
        case isCreatable(Bool)
    }
    struct State{
        var name: String = ""
        var description:String = ""
        var isCreatable: Bool = false
    }
    func mutate(action: Action) -> Observable<Mutation> {
        fatalError("It must be override!!")
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setDescription(let str):
            state.description = str
        case .setName(let str):
            state.name = str
        case .isCreatable(let avail):
            state.isCreatable = avail
        }
        return state
    }
}
