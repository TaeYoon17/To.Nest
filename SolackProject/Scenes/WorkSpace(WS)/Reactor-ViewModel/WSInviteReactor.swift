//
//  WSInviteReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import RxSwift
import ReactorKit
final class WSInviteReactor: Reactor{
    var initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    var emailText:String = ""
    enum Action{
        case inviteAction
        case setEmail(String)
    }
    enum Mutation{
        case setInvitable(Bool)
        case setEmailText(String)
        case setLoading(Bool)
        case isClose(Bool)
        case setToast(WSInviteToastType?)
    }
    struct State{
        var isLoading = false
        var isInvitable = false
        var isClose = false
        var email = ""
        var toast: ToastType? = nil
    }
    init(_ provider:ServiceProviderProtocol){
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .inviteAction:
            if self.emailText.validationEmail(){
                provider.wsService.inviteUser(emailText: emailText)
                return Observable.concat([.just(.setLoading(true))])
            }else{
                return Observable.concat([.just(.setToast(.emailFailed)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                                        .just(.setToast(nil))
                                         ])
            }
            
        case .setEmail(let emailText):
            self.emailText = emailText
            return Observable.concat([
                .just(.setInvitable(!emailText.isEmpty)),
                .just(.setEmailText(emailText))
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setEmailText(let text):
            state.email = text
        case .setInvitable(let invitable):
            state.isInvitable = invitable
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        case .isClose(let isClose):
            state.isClose = isClose
        case .setToast(let toast):
            state.toast = toast
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let wsMutation = provider.wsService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else { return Observable.concat([])}
            switch event{
            case .invited(let response):
                return Observable.concat([.just(.isClose(true))])
            case .failed(let wsFailed):
                return switch wsFailed{
                case .unknwonAccount: Observable.concat([
                    .just(.setToast(.notUser)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                    .just(.setToast(nil))
                ])
                case .doubled: Observable.concat([
                    .just(.setToast(.doubled)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                    .just(.setToast(nil))
                ])
                default: Observable.concat([])
                }
            default:
                return Observable.concat([])
            }
        }
        return Observable.merge(mutation,wsMutation)
    }
}
