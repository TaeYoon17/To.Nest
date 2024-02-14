//
//  CHSettingReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/24/24.
//
import Foundation
import ReactorKit
import RxSwift
enum CHEditingType:String{
    case exit
    case delete
    case adminChange
    case edit
}
enum CHOwnerType{
    case my
    case others
}
final class CHSettingReactor:Reactor{
    var initialState: State = .init()
    @DefaultsState(\.userID) var userID
    weak var provider: ServiceProviderProtocol!
    var info = CHInfo()
    var title:String
    var channelID:Int
    enum Action{
        case initAction
        case actionDialog(CHEditingType)
        case deleteAction
        case exitAction
    }
    enum Mutation{
        case setDialog(CHEditingType?)
        case setOnwer(CHOwnerType?)
        case setMembers([UserResponse])
        case setInfo(title:String,description:String)
        case isLoading(Bool)
        case isClose(Bool)
    }
    struct State{
        var title:String = ""
        var description:String = ""
        var dialog: CHEditingType? = nil
        var ownerType: CHOwnerType? = nil
        var members: [UserResponse] = []
        var isLoading:Bool = false
        var isClose:Bool = false
    }
    init(_ provider: ServiceProviderProtocol,channelTitle:String,channelID:Int) {
        self.title = channelTitle
        self.channelID = channelID
        self.provider = provider
        self.info.name = channelTitle
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initAction:
            provider.chService.check(title: title)
            return Observable.concat([])
        case .actionDialog(let type):
            return Observable.concat([
                .just(.setDialog(type)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                .just(.setDialog(nil))
            ])
        case .exitAction:
            provider.chService.exit(channelID: channelID, channelName: title)
            return Observable.concat([ .just(.isLoading(true))])
        case .deleteAction:
            provider.chService.delete(channelID: channelID, channelName: self.title)
            return Observable.concat([ .just(.isLoading(true))])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setDialog(let dialog): state.dialog = dialog
        case .setOnwer(let owner):
            state.ownerType = owner
        case .setMembers(let members):
            state.members = members
        case .setInfo(title: let title, description: let description):
            state.title = title
            state.description = description
        case .isLoading(let isLoading):
            state.isLoading = isLoading
        case .isClose(let isClose):
            state.isClose = isClose
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let channelMutation = provider.chService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {fatalError("이게 이상해")}
            switch event{
            case .check(let response),.channelAdminChange(let response):
                if response.channelID == self.channelID{
                    self.title = response.name
                    self.info.name = response.name
                    self.info.description = response.description ?? ""
                    let ownerType = response.ownerID == self.userID ? CHOwnerType.my : CHOwnerType.others
                    return Observable.concat([
                        .just(.setInfo(title: response.name, description: response.description ?? "")),
                        .just(.setOnwer(ownerType)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.setOnwer(nil))
                    ])
                }else{
                    return Observable.concat([])
                }
            case .channelUsers(id: let channelID, let response):
                if channelID == self.channelID{
                    return Observable.concat([.just(.setMembers(response))])
                }else{
                    return Observable.concat([])
                }
            case .update(let response):
                guard response.channelID == self.channelID else {return Observable.concat([]) }
                self.title = response.name
                self.info.name = response.name
                self.info.description = response.description ?? ""
                return Observable.concat([
                    .just(.setInfo(title: response.name, description: response.description ?? ""))
                ])
            case .delete(chID: let chID),.exit(chID: let chID):
                return Observable.concat([
                    .just(.isClose(true))
                ])
            default: return Observable.concat([])
            }
        }
        return Observable.merge(mutation,channelMutation)
    }
}
