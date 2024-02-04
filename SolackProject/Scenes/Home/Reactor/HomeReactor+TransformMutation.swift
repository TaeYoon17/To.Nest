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
            case .invited(_):
                return Observable.concat([
                    .just(.setToast(WSInviteToastType.inviteSuccess)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance),
                    .just(.setToast(nil))
                ])
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
                responses.forEach { res in // 채널들의 메시지들 업데이트
                    self.provider.msgService.getChannelDatas(chID: res.channelID, chName: res.name)
                }
                return Observable.concat([.just(.setChannelList(responses)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)])
            case .unreads(let unreads):
                return Observable.concat([
                    .just(.setUnreads(unreads)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                    .just(.setUnreads(nil))
                ])
            case .update(let response):
                guard response.workspaceID == mainWS else {return Observable.concat([])}
                // 여기 수정해야 할 수도..? unreads도 다 같이 부르는 문제가 발생하긴 한다...
                provider.chService.checkAllMy()
                return Observable.concat([])
            case .delete(chID: let chID):
                provider.chService.checkAllMy()
                return Observable.concat([])
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
    var dmMutation: Observable<Mutation>{
        provider.dmService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .allMy(let responses):return Observable.concat([])
            }
        }
    }
}
