//
//  CHAdminChangeReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/12/24.
//

import Foundation
import ReactorKit
enum CHManagerDialog{
    case nonMember
    case checkAlert(userNick:String,userID:Int)
}
final class CHAdminChangeReactor: Reactor{
    let initialState: State = .init()
    let provider: ServiceProviderProtocol
    var channelName:String
    var channelID:Int
    @DefaultsState(\.userID) var userID
    enum Action{
        case initAction
        case closeAction
        case changeAdminAction(userName:String,userID:Int)
        case confirmAdminChangeAction(userID:Int)
    }
    enum Mutataion{
        case setMembers([UserResponse])
        case setDialog(CHManagerDialog?)
        case setToast(ToastType?)
        case setClose(Bool)
    }
    struct State{
        var members:[UserResponse] = []
        var chManagerDialog:CHManagerDialog? = nil
        var isClose = false
        var toast: ToastType? = nil
    }
    init(provider: ServiceProviderProtocol,channelID:Int,channelTitle:String) {
        self.provider = provider
        self.channelID = channelID
        self.channelName = channelTitle
    }
    func mutate(action: Action) -> Observable<Mutataion> {
        var concatList:[Observable<Mutation>] = []
        switch action{
        case .initAction:
            provider.chService.checkUser(channelID: channelID, title: channelName)
        case .changeAdminAction(userName: let userName, userID: let userID):
            concatList.append(.just(.setDialog(.checkAlert(userNick: userName, userID: userID))).delay(.microseconds(100), scheduler: MainScheduler.instance))
            concatList.append(.just(.setDialog(nil)))
        case .confirmAdminChangeAction(userID: let userID):
            provider.chService.changeAdmin(userID: userID, channelName: channelName)
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
            st.chManagerDialog = dialog
        case .setClose(let close ):
            st.isClose = close
        case .setToast(let toast):
            st.toast = toast
        }
        return st
    }
    func transform(mutation: Observable<Mutataion>) -> Observable<Mutataion> {
        return Observable.merge(mutation,chTransform)
    }
}
extension CHAdminChangeReactor{
    var chTransform: Observable<Mutation>{
        provider.chService.event.flatMap { [weak self] event -> Observable<Mutation> in
            switch event{
            case .channelUsers(id: let chID, var users):
                guard chID == self?.channelID else {return Observable.concat([])}
                users = users.filter { $0.userID != self?.userID }
                if users.isEmpty{
                    return Observable.concat([.just(.setDialog(.nonMember))])
                }else{
                    return Observable.concat([ .just(.setMembers(users)) ])
                }
            case .channelAdminChange(let response):
                return Observable.concat([.just(.setClose(true))])
            case .failed(let failed):
                switch failed{
                case .nonExistData: return Observable.concat([.just(.setToast(CHToastType.isNotChannelAdmin)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                                                              .just(.setToast(nil))])
                default: return Observable.concat([])
                }
            default: return Observable.concat([])
            }
        }
    }
}
