//
//  CHWriterReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/15/24.
//

import Foundation
import RxSwift
import ReactorKit
class WriterReactor<Failed:FailedProtocol,Toast:ToastType>:Reactor{
    var initialState = State()
    weak var provider: ServiceProviderProtocol!
    var disposeBag = DisposeBag()
    enum Action{
        case setName(String)
        case setDescription(String)
        case confirmAction
    }
    enum Mutation{
        case setName(String)
        case setDescription(String)
        case isCreatable(Bool)
        case isLoading(Bool)
        case failAlert(Failed?)
        case toastType(Toast)
        case isClose(Bool)
    }
    struct State{
        var name: String = ""
        var description:String = ""
        var erroredName:Bool = false
        var erroredDescription:Bool = false
        var isCreatable: Bool = false
        var isLoading:Bool = false
        var failAlert: Failed? = nil
        var toast: Toast? = nil
        var isClose: Bool = false
    }
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
        
    }
    func mutate(action: Action) -> Observable<Mutation> {
        writerMutate(action: action)
    }
    func writerMutate(action: Action) -> Observable<Mutation>{
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
        case .isLoading(let loading):
            state.isLoading = loading
        case .failAlert(let alert):
            state.failAlert = alert
        case .isClose(let close):
            state.isClose = close
        case .toastType(let toast):
            state.toast = toast
        }
        return state
    }
    func transform(state: Observable<State>) -> Observable<State> {
        writerTransform(state: state)
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        writerTransformtransform(mutation: mutation)
    }
    func writerTransform(state: Observable<State>) -> Observable<State>{
        fatalError("It must be override!!")
    }
    func writerTransformtransform(mutation: Observable<Mutation>) -> Observable<Mutation>{
        fatalError("It must be override!!")
    } 
}
