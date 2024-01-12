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
        case imageData(Data)
        case create
    }
    enum Mutation{
        case setName(String)
        case setDescription(String)
        case isCreatable(Bool)
        case isLoading(Bool)
    }
    struct State{
        var name: String = ""
        var description:String = ""
        var isCreatable: Bool = false
        var isLoading:Bool = false
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
        }
        return state
    }
    func transform(mutation: Observable<WSwriterReactor.Mutation>) -> Observable<WSwriterReactor.Mutation> {
        print("transform 생성!!")
        let res = provider.wsService.event.flatMap { event -> Observable<WSwriterReactor.Mutation> in
            switch event{
            case .create(let response):
                print("워크 스페이스 만들기 성공!!")
                return .just(.isLoading(false))
            case .requireReSign:
                AppManager.shared.userAccessable.onNext(false)
                return .just(.isLoading(false))
            default:
                return Observable.concat([
                    .just(.isLoading(false))
                ])
            }
        }
        return Observable.merge(mutation,res)
    }
}
