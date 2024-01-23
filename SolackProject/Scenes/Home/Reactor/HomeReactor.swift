//
//  HomeReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
enum HomePresent:Equatable{
    case create
    case explore
    case chatting(chID:Int)
}
final class HomeReactor: Reactor{
    let initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    @DefaultsState(\.mainWS) var mainWS
    enum Action{
        case setPresent(HomePresent?)
        case setMainWS(wsID:String)
        case initMainWS
    }
    enum Mutation{
        case channelDialog(HomePresent?)
        case setChannelList([CHResponse]?)
        case isMasking(Bool)
        case wsTitle(String)
        case wsLogo(String)
    }
    struct State{
        var channelDialog:HomePresent? = nil
        var isMasking: Bool? = nil
        var channelList:[CHResponse]? = nil
        var wsTitle:String = ""
        var wsLogo: String = ""
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
        case .setChannelList(let list):
            state.channelList = list
        case .isMasking(let isMasking):
            state.isMasking = isMasking
        case .wsLogo(let logo):
            state.wsLogo = logo
        case .wsTitle(let title):
            state.wsTitle = title
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let wsService = wsMutationTransform
        let chService = chMutationTransform
        return Observable.merge(mutation,wsService,chService)
    }
}
