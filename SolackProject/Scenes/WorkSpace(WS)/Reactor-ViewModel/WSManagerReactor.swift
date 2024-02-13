//
//  WSManagerReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import Foundation
import ReactorKit
enum WSManagerDialog{
    case nonMember
    case checkAlert(userNick:String,userID:Int)
}
final class WSManagerReactor: Reactor{
    let initialState: State = .init()
    let provider: ServiceProviderProtocol
    enum Action{
        case initAction
        case closeAction
        case changeAdminAction(userName:String,userID:Int)
        case confirmAdminChangeAction(userID:Int)
    }
    enum Mutataion{
        case setMembers([UserResponse])
        case setDialog(WSManagerDialog?)
        case setToast(ToastType?)
        case setClose(Bool)
    }
    struct State{
        var members:[UserResponse] = []
        var wsManagerDialog:WSManagerDialog? = nil
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
        case .changeAdminAction(userName: let userName, userID: let userID):
            concatList.append(.just(.setDialog(.checkAlert(userNick: userName, userID: userID))).delay(.microseconds(100), scheduler: MainScheduler.instance))
            concatList.append(.just(.setDialog(nil)))
        case .confirmAdminChangeAction(userID: let userID):
            provider.wsService.changeAdmin(userID: userID)
        case .closeAction:
            concatList.append(.just(.setClose(true)))
        }
        return Observable.concat(concatList)
    }
    func reduce(state: State, mutation: Mutataion) -> State {
        var st = state
        switch mutation{
        case .setMembers(let members):
            st.members = members
        case .setDialog(let dialog):
            st.wsManagerDialog = dialog
        case .setClose(let close ):
            st.isClose = close
        case .setToast(let toast):
            st.toast = toast
        }
        return st
    }
    func transform(mutation: Observable<Mutataion>) -> Observable<Mutataion> {
        return Observable.merge(mutation,wsTransform)
    }
}
extension WSManagerReactor{
    var wsTransform: Observable<Mutation>{
        provider.wsService.event.flatMap { [weak self] event in
            var concatList:[Observable<Mutation>] = []
            switch event{
            case .wsAllMembers(let members):
                concatList.append(.just(.setMembers(members)))
            case .adminChanged(_):
                concatList.append(.just(.setClose(true)))
            case .failed(let wsFailed):
                switch wsFailed{
                case .nonAuthority:
                    concatList.append(.just(.setToast(WSToastType.notAuthority)).delay(.microseconds(100), scheduler: MainScheduler.instance))
                default:
                    concatList.append(.just(.setToast(WSToastType.inviteNotManager)).delay(.microseconds(100), scheduler: MainScheduler.instance))
                }
                concatList.append(.just(.setToast(nil)))
            default: break
            }
            return Observable.concat(concatList)
        }
    }
}
