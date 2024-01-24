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
    case edit
}
final class CHSettingReactor:Reactor{
    var initialState: State = .init()
    var provider: ServiceProviderProtocol!
    enum Action{
        case actionEdit
        case actionExit
        case actionChangeAdmin
        case actionDelete
    }
    enum Mutation{
        case setDialog(CHEditingType?)
    }
    struct State{
        var dialog: CHEditingType? = nil
    }
    init(_ provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
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
        }
        return state
    }
}
