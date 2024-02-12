//
//  DMInviteReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import Foundation
import ReactorKit
enum DMExploreDialog{
    case nonMember
    case checkAlert(userNick:String,userID:Int)
}
final class DMExploreReactor: Reactor{
    let initialState: State = .init()
    let provider: ServiceProviderProtocol
    @DefaultsState(\.userID) var userID
    @DefaultsState(\.mainWS) var mainWS
    enum Action{
        case initAction
        case closeAction
        case goRoomsAction(userID:Int)
    }
    enum Mutataion{
        case setMembers([UserResponse])
        case setRooms([DMRoomResponse])
        case setDialog(DMExploreDialog?)
        case setToast(ToastType?)
        case setClose(Bool)
    }
    struct State{
        var members:[UserResponse] = []
        var dmInviteDialog:DMExploreDialog? = nil
        var existedRooms:[DMRoomResponse] = []
        var isClose = false
        var toast: ToastType? = nil
    }
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutataion> {
        var concatList:[Observable<Mutation>] = []
        switch action{
        case .initAction:
            provider.wsService.checkAllMembers()
            provider.dmService.checkAll(wsID: mainWS.id)
        case .closeAction:
            concatList.append(.just(.setClose(true)))
        case .goRoomsAction(userID: let userID):
            if let roomResponse = currentState.existedRooms.first(where: { $0.user.userID == userID }){
                provider.dmService.transition.onNext(.goDM(id: roomResponse.roomID, userResponse: roomResponse.user))
                concatList.append(.just(.setClose(true)))
            }else{
                if let userResponse = currentState.members.first { $0.userID == userID }{
                    provider.dmService.getRoomID(user: userResponse)
                }else{
                    concatList.append(.just(.setToast(DMToastType.dmMemberError)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance))
                    concatList.append(.just(.setToast(nil)))
                }
            }
        }
        return Observable.concat(concatList)
    }
    func reduce(state: State, mutation: Mutataion) -> State {
        var st = state
        switch mutation{
        case .setMembers(let members):
            st.members = members
        case .setDialog(let dialog):
            st.dmInviteDialog = dialog
        case .setClose(let close ):
            st.isClose = close
        case .setToast(let toast):
            st.toast = toast
        case .setRooms(let rooms):
            st.existedRooms = rooms
        }
        return st
    }
    func transform(mutation: Observable<Mutataion>) -> Observable<Mutataion> {
        return Observable.merge(mutation,wsTransform,dmTransform)
    }
}
extension DMExploreReactor{
    var wsTransform: Observable<Mutation>{
        return provider.wsService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .wsAllMembers(let responses):
                return Observable.concat([.just(.setMembers(responses))])
            default: return Observable.concat([])
            }
        }
    }
    var dmTransform: Observable<Mutation>{
        provider.dmService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .allMy(let roomResponses):
                return Observable.concat([.just(.setRooms(roomResponses))])
            default: return Observable.concat([])
            }
        }
    }
}
