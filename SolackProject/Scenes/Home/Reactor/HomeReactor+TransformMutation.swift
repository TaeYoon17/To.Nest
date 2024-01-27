//
//  HomeReactor+TransformMutation.swift
//  SolackProject
//
//  Created by 김태윤 on 1/24/24.
//

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
extension HomeReactor{
    var wsMutationTransform:Observable<Mutation>{
        provider.wsService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else{return Observable.concat([])}
            switch event{
            case .homeWS(let response):
                if let response{
                    provider.chService.checkAllMy()
                    return Observable.concat([.just(.isMasking(false)),
                                              .just(.wsTitle(response.name)),
                                              .just(.wsLogo(response.thumbnail)),
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
    }
    var chMutationTransform:Observable<Mutation>{
        let service = provider.chService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .create(let chInfo):
                provider.wsService.setHomeWS(wsID: mainWS)
                return Observable.concat([])
            case .allMy(let responses):
                return Observable.concat([.just(.setChannelList(responses))])
            default: return Observable.concat([])
            }
        }
        let transition = provider.chService.transition.flatMap {[weak self] transition -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch transition{
            case .goChatting(let chID,let chName): return Observable.concat([
                .just(.channelDialog(.chatting(chID: chID, chName: chName))).delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance),
                .just(.channelDialog(nil))
            ])
            }
        }
        return Observable.merge(service,transition)
    }
}
