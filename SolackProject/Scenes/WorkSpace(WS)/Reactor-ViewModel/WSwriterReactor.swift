//
//  WSwriterReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//
import Foundation
import RxSwift
import ReactorKit
class WSwriterReactor:Reactor{
    var initialState = State()
    weak var provider: ServiceProviderProtocol!
    
    enum Action{
        case setName(String)
        case setDescription(String)
        case setImageData(Data)
        case confirmAction
    }
    enum Mutation{
        case setName(String)
        case setDescription(String)
        case isCreatable(Bool)
        case isLoading(Bool)
        case failAlert(WSFailed?)
        case isClose(Bool)
        case imageData(Data?)
    }
    struct State{
        var name: String = ""
        var description:String = ""
        var isCreatable: Bool = false
        var isLoading:Bool = false
        var failAlert: WSFailed? = nil
        var isClose: Bool = false
        var imageData:Data? = nil
    }
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
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
        case .isLoading(let loading):
            state.isLoading = loading
        case .failAlert(let alert):
            state.failAlert = alert
        case .isClose(let close):
            state.isClose = close
        case .imageData(let data):
            state.imageData = data
        }
        return state
    }
    func transform(mutation: Observable<WSwriterReactor.Mutation>) -> Observable<WSwriterReactor.Mutation> {
        writerTransform(mutation: mutation)
    }
    func transform(state: Observable<State>) -> Observable<State> {
        writerTransform(state: state)
    }
    func writerTransform(state: Observable<State>) -> Observable<State>{
        fatalError("It must be override!!")
    }
    func writerTransform(mutation: Observable<WSwriterReactor.Mutation>) -> Observable<WSwriterReactor.Mutation>{
        fatalError("It must be override!!")
    }
}
