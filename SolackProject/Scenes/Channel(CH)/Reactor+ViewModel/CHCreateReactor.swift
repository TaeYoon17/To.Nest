//
//  CHCreateReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/23/24.
//

import Foundation
import RxSwift
import RxCocoa
final class CHCreateReactor: CHWriterReactor{
    typealias Mut = Observable<WriterReactor<CHFailed, CHToastType>.Mutation>
    var info = CHInfo()
    override func writerMutate(action: WriterReactor<CHFailed, CHToastType>.Action) -> Observable<WriterReactor<CHFailed, CHToastType>.Mutation> {
        switch action{
        case .confirmAction:
            provider.chService.create(info)
            return Observable.concat([])
        case .setDescription(let description):
            info.description = description
            return .just(.setDescription(description))
        case .setName(let name):
            info.name = name
            return .just(.setName(name))
        }
    }
    override func writerTransform(state: Observable<CHReactrable.State>) -> Observable<CHReactrable.State> {
        state.flatMap { [weak self] state -> Observable<State> in
            guard let self else {return .just(state)}
            var st = state
            st.isCreatable = !st.name.isEmpty
            return .just(st)
        }
    }
    // transform에 아무 값도 안넘기면 변하가 일어나지 않는다
    
    override func writerTransformtransform(mutation: Mut) -> Mut {
        let res = provider.chService.event.flatMap {[weak self] event -> Mut in
            switch event{
            case .create(_):
                print("여기 받음")
                return Observable.concat([.just(.isClose(true))])
            case .failed(let failed):
                switch failed{
                case .doubled:
                    return Observable.concat([
                    .just(.toastType(.double)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)
                ])
                default: return Observable.concat([])
                }
            default:return Observable.concat([])
            }
        }
        return Observable.merge(mutation,res)
    }
}
