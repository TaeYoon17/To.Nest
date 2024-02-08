//
//  DMMainReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import ReactorKit
import RxSwift
enum DMMainPresent:Equatable{
    case room(roomID:Int,user:UserResponse)
}
final class DMMainReactor: Reactor{
    @DefaultsState(\.mainWS) var mainWS
    var initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
    }
    enum Action{
        case initAction
        case setRoom(UserResponse)
    }
    enum Mutation{
        case setPresent(DMMainPresent?)
        case setMembsers([UserResponse])
        case appendMembers([UserResponse])
        case setRooms([DMRoomResponse])
        case setWSThumbnail(String)
        case isProfileUpdated(Bool)
    }
    struct State{
        var membsers:[UserResponse] = []
        var rooms:[DMRoomResponse] = []
        var wsThumbnail:String = ""
        var isProfileUpdated = false
        var dialog:DMMainPresent? = nil
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initAction:
            provider.dmService.checkAll(wsID: mainWS.id)
            return Observable.concat([])
        case .setRoom(let response):
            provider.dmService.getRoomID(user: response)
            return Observable.concat([])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setMembsers(let members):
            state.membsers = members
        case .appendMembers(let members):
            state.membsers.append(contentsOf: members)
        case .setWSThumbnail(let thumbnail):
            state.wsThumbnail = thumbnail
        case .isProfileUpdated(let updated):
            state.isProfileUpdated = updated
        case .setPresent(let present):
            state.dialog = present
        case .setRooms(let rooms):
            state.rooms = rooms
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge([mutation,workspaceMutation,profileMutation,dmMutation])
    }
}
