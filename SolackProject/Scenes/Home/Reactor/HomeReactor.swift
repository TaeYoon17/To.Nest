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
        let wsService = provider.wsService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else{return Observable.concat([])}
            switch event{
            case .homeWS(let response):
                if let response{
                    return Observable.concat([.just(.isMasking(false)),
                                              .just(.wsTitle(response.name)),
                                              .just(.wsLogo(response.thumbnail)),
                                              .just(.setChannelList(response.channels))
                                              ])
                }else{
                    return Observable.concat([.just(.isMasking(true))])
                }
            case .create(let response): // 새로 만든 것
                // 현재 마스크가 되어있음... 워크스페이스가 없음...
                if let isMask = currentState.isMasking, isMask == true{
                    return Observable.concat([
                        .just(.isMasking(false)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.wsTitle(response.name)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.wsLogo(response.thumbnail)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.setChannelList([]))
                    ])
                }else{ // 메인에 이미 워크스페이스가 존재했음
                    return Observable.concat([])
                }
            default: return Observable.concat([])
            }
        }
        let chService = provider.chService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .create(let chInfo):
                provider.wsService.setHomeWS(wsID: mainWS)
                return Observable.concat([])
            default: return Observable.concat([])
            }
        }
        return Observable.merge(mutation,wsService,chService)
    }
}
