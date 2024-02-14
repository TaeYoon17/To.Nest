//
//  CHEditReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CHEditReactor: CHWriterReactor{
    typealias Mut = Observable<WriterReactor<CHFailed, CHToastType>.Mutation>
    var info: CHInfo
    init(provider:ServiceProviderProtocol,info: CHInfo) {
        self.info = info
        super.init(provider)
        self.initialState = .init(name: info.name, description: info.description, erroredName: false, erroredDescription: false, isCreatable: false, isLoading: false, failAlert: nil, toast: nil, isClose: false)
        Task{@MainActor in
            action.onNext(.setName(info.name))
            action.onNext(.setDescription(info.description))
        }
    }
    override func writerMutate(action: WriterReactor<CHFailed, CHToastType>.Action) -> Observable<WriterReactor<CHFailed, CHToastType>.Mutation> {
        switch action {
        case .setName(let name):
            info.name = name
            return .just(.setName(name))
        case .setDescription(let description):
            info.description = description
            return .just(.setDescription(description))
        case .confirmAction:
            provider.chService.edit(channelName: initialState.name, info)
            return Observable.concat([
                .just(.isLoading(true))
            ])
        }
    }
    override func writerTransform(state: Observable<CHReactrable.State>) -> Observable<CHReactrable.State> {
        state.flatMap { [weak self] state -> Observable<State> in
            guard let self else {return .just(state)}
            var st = state
            st.isCreatable = !st.name.isEmpty && st.name != initialState.name
            return .just(st)
        }
    }
    override func writerTransformtransform(mutation: Mut) -> Mut {
        let chMutation = provider.chService.event.flatMap { [weak self] event -> Mut in
            switch event{
            case .update(let response):
                return Observable.concat([
                    .just(.isLoading(false)),
                    .just(.isClose(true))
                ])
            default: return Observable.concat([])
            }
        }
        return Observable.merge(mutation,chMutation)
    }
}
