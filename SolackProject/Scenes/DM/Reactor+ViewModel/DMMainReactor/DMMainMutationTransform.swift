//
//  DMMainReactorMutationTransform.swift
//  SolackProject
//
//  Created by 김태윤 on 2/7/24.
//

import Foundation
import ReactorKit
import RxSwift
extension DMMainReactor{
    var workspaceMutation: Observable<Mutation>{
        provider.wsService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            var mutList:[Observable<Mutation>] = []
            switch event{
            case .homeWS(let wsResponse):
                guard let members = wsResponse?.workspaceMembers else {return Observable.concat([])}
                if let profileImage = wsResponse?.thumbnail{
                    mutList.append(.just(.setWSThumbnail(profileImage)).delay(.microseconds(100), scheduler: MainScheduler.instance))
                }
                mutList.append(.just(.setMembsers(members)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance))
            case .wsAllMembers(let response):
                print("워크스페이스 멤버 가져오기 성공!!")
                mutList.append(
                    .just(.setMembsers(response)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                )
            case .invited(let response):
                if !currentState.membsers.contains(response){
                    mutList.append(
                        .just(.appendMembers([response])).debounce(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                    )
                }
            default: break
            }
            return Observable.concat(mutList)
        }
    }
}

extension DMMainReactor{
    var profileMutation:Observable<Mutation>{
        provider.profileService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else{return Observable.concat([])}
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
extension DMMainReactor{
    var dmMutation: Observable<Mutation>{
        provider.dmService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            var mutations: [Observable<Mutation>] = []
            switch event{
            case .allMy(let responses):
                for res in responses{
                    self.provider.msgService.getDirectMessageDatas(roomID: res.roomID, userID: res.user.userID)
                }
                mutations.append(.just(.setRooms(responses)).subscribe(on:MainScheduler.instance))
            case .dmRoomID(id: let id, userResponse: let response):
                mutations.append(.just(.setPresent(.room(roomID: id, user: response))).delay(.microseconds(100), scheduler: MainScheduler.instance))
                mutations.append(.just(.setPresent(nil)))
            case .unreads(let responses):
                mutations.append(.just(.setUnreads(responses)).delay(.microseconds(100), scheduler: MainScheduler.instance))
                break
            }
            return Observable.concat(mutations)
        }
    }
}
