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
//MARK: -- 워크스페이스 Transform
extension HomeReactor{
    var wsMutationTransform:Observable<Mutation>{
        provider.wsService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else{return Observable.concat([])}
            var observeList:[Observable<Mutation>] = []
            switch event{
            case .homeWS(let response):
                if let response{
                    provider.chService.checkAllMy()
                    provider.dmService.checkAll(wsID: mainWS.id)
                    observeList.append(contentsOf: [.just(.isMasking(false)),
                                                    .just(.wsTitle(response.name)),
                                                    .just(.wsLogo(response.thumbnail)),
                                                    ])
                }else{
                    observeList.append(.just(.isMasking(true)))
                }
            case .create(let response): // 새로 만든 것
                // 현재 마스크가 되어있음... 워크스페이스가 없음...
                if let isMask = currentState.isMasking, isMask == true{
                    observeList.append(contentsOf: [
                        .just(.isMasking(false)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.wsTitle(response.name)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.wsLogo(response.thumbnail)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.setChannelList([]))
                    ])
                }
            case .invited(_):
                observeList.append(contentsOf: [
                    .just(.setToast(WSInviteToastType.inviteSuccess)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance),
                    .just(.setToast(nil))
                ])
            default: break
            }
            return Observable.concat(observeList)
        }
    }
}
//MARK: -- 채널 Transform
extension HomeReactor{
    var chMutationTransform:Observable<Mutation>{
        let service = provider.chService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .create(let chInfo):
                provider.wsService.setHomeWS(wsID: mainWS.id)
                return Observable.concat([])
            case .allMy(let responses):
                responses.forEach { res in // 채널들의 메시지들 업데이트
                    self.provider.msgService.getChannelDatas(chID: res.channelID, chName: res.name)
                }
                return Observable.concat([.just(.setChannelList(responses)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)])
            case .unreads(let unreads):
                return Observable.concat([
                    .just(.setChannelUnreads(unreads)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                    .just(.setChannelUnreads(nil))
                ])
            case .update(let response):
                guard response.workspaceID == mainWS.id else {return Observable.concat([])}
                // 여기 수정해야 할 수도..? unreads도 다 같이 부르는 문제가 발생하긴 한다...
                provider.chService.checkAllMy()
                return Observable.concat([])
            case .delete(chID: let chID),.exit(chID: let chID):
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
}
//MARK: -- DM 기록 Transform
extension HomeReactor{
    var dmMutationTransform: Observable<Mutation>{
        let eventMutation = provider.dmService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .allMy(let responses):
                return Observable.concat([.just(.setDMList(responses))])
            case .unreads(let unreads): return Observable.concat(.just(.setDMUnreads(unreads)))

            default: return Observable.concat([])
            }
        }
        let transitionMutation = provider.dmService.transition.flatMap { [weak self] transition -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch transition{
            case .goDM(id: let roomID, userResponse: let userResponse):
                return Observable.concat([
                    .just(.channelDialog(.dm(roomID: roomID, user: userResponse))).delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance),
                    .just(.channelDialog(nil))
                ])
            }
        }
        return Observable.merge(eventMutation,transitionMutation)
    }
}
//MARK: -- Profile Transform
extension HomeReactor{
    var profileMutationTransform: Observable<Mutation>{
        provider.profileService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .updatedImage:
                return Observable.concat([
                    .just(Mutation.isProfileUpdated(true)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                   .just(Mutation.isProfileUpdated(false))
              ])
            default: return Observable.concat([])
            }
        }
    }
}
