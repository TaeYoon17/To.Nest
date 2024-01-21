//
//  WScreateReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import Foundation
import ReactorKit
import RxSwift
final class WScreateReactor: WSwriterReactor{
    var wsInfo = WSInfo()
    override func mutate(action: WSwriterReactor.Action) -> Observable<WSwriterReactor.Mutation> {
        switch action{
        case .setDescription(let str):
            self.wsInfo.description = str
            return Observable.concat([
                .just(Mutation.setDescription(str))
            ])
        case .setName(let str):
            let newStr:String = str.count > 30 ? String(str.prefix(30)) : str
            self.wsInfo.name = str
            return Observable.concat([.just(.setName(str)),
                                      .just(Mutation.isCreatable(!str.isEmpty))
            ])
        case .confirmAction:
            print(wsInfo)
            provider.wsService.create(wsInfo)
            return Observable.concat([.just(.isLoading(true))])
        case .setImageData(let data):
            self.wsInfo.image = data
            print("이미지 받아오기!!")
            return Observable.concat([.just(.imageData(data))])
        }
    }
    override func writerTransform(state: Observable<WSwriterReactor.State>) -> Observable<WSwriterReactor.State> {
        state.flatMap {[weak self] state -> Observable<State> in
            guard let self else{return .just(state)}
            var st = state
            // 이건 수정할 때 적용되어야함
            st.isCreatable = !st.name.isEmpty && st.imageData != nil
            return .just(st)
        }
    }
    override func writerTransform(mutation: Observable<WSwriterReactor.Mutation>) -> Observable<WSwriterReactor.Mutation> {
        let res = provider.wsService.event.flatMap { event -> Observable<WSwriterReactor.Mutation> in
            switch event{
            case .create(let response):
                return Observable.concat([
                    .just(.isLoading(false)),
                    .just(.isClose(true))
                ])
            case .requireReSign:
                AppManager.shared.userAccessable.onNext(false)
                return .just(.isLoading(false))
            case .failed(let failed):
                let failAlert = switch failed{
                case .nonAuthority: Mutation.failAlert(.nonAuthority)
                case .lackCoin: Mutation.failAlert(.lackCoin)
                default: Mutation.failAlert(nil)
                }
                return Observable.concat([
                    .just(.isLoading(false)),
                    .just(failAlert).delay(.nanoseconds(100), scheduler: MainScheduler.asyncInstance),
                    .just(.failAlert(nil)),
                ])
            default:
                return Observable.concat([
                    .just(.isLoading(false))
                ])
            }
        }
        return Observable.merge(mutation,res)
    }
}
