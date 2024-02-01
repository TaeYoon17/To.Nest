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
    var title:String
    var channelID:Int
    enum Action{
        case initAction
        case actionEdit
        case actionExit
        case actionChangeAdmin
        case actionDelete
    }
    enum Mutation{
        case setDialog(CHEditingType?)
        case setOnwer(CHOwnerType?)
        case setMembers([UserResponse])
    }
    struct State{
        var dialog: CHEditingType? = nil
        var ownerType: CHOwnerType? = nil
        var members: [UserResponse] = []
    }
    init(_ provider: ServiceProviderProtocol,channelTitle:String,channelID:Int) {
        self.title = channelTitle
        self.channelID = channelID
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initAction:
            provider.chService.check(title: title)
            return Observable.concat([])
        case .actionChangeAdmin: return Observable.concat([])
        case .actionDelete: return Observable.concat([
            .just(.setDialog(.delete)).delay(.microseconds(100), scheduler: MainScheduler.instance),
            .just(.setDialog(nil))
        ])
        case .actionEdit: return Observable.concat([
            .just(.setDialog(.edit)).delay(.microseconds(100), scheduler: MainScheduler.instance),
            .just(.setDialog(nil))
        ])
        case .actionExit: return Observable.concat([
            .just(.setDialog(.exit)).delay(.microseconds(100), scheduler: MainScheduler.instance),
            .just(.setDialog(nil))
        ])
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
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let channelMutation = provider.chService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {fatalError("이게 이상해")}
            switch event{
            case .check(let response):
                if response.channelID == self.channelID{
                    self.title = response.name
                    let ownerType = response.ownerID == self.userID ? CHOwnerType.my : CHOwnerType.others
                    return Observable.concat([
                        .just(.setOnwer(ownerType)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.setOnwer(nil))
                    ])
                }else{
                    return Observable.concat([])
                }
            case .channelUsers(id: let channelID, let response):
                if channelID == self.channelID{
                    print("channelUsers \(response)")
                    return Observable.concat([.just(.setMembers(response))])
                }else{
                    return Observable.concat([])
                }
            default: return Observable.concat([])
            }
        }
        return Observable.merge(mutation,channelMutation)
    }
}
