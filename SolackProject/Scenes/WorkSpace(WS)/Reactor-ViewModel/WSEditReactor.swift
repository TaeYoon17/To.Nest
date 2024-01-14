//
//  WSEditReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import Foundation
import ReactorKit
import RxSwift
final class WSEditReactor: WSwriterReactor{
    var wsInfo = WSInfo()
    private var id:String
    var isImageUploaded = false
    init(provider:ServiceProviderProtocol,wsInfo: WorkSpaceInfo,id:String) {
        self.wsInfo = wsInfo
        self.id = id
        super.init(provider)
        self.initialState = .init(name: wsInfo.name,
                                  description: wsInfo.description,
                                  isCreatable: false,
                                  isLoading: false,
                                  failAlert: nil,
                                  isClose: false,
                                  imageData: wsInfo.image)
    }
    
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
            return Observable.concat([.just(.setName(str)) ])
        case .confirmAction:
            print(wsInfo)
            provider.wsService.edit(wsInfo, id: id)
            return Observable.concat([.just(.isLoading(true))])
        case .setImageData(let data):
            self.wsInfo.image = data
            self.isImageUploaded = true
            return Observable.concat([.just(.imageData(data))])
        }
    }
    override func writerTransform(state: Observable<WSwriterReactor.State>) -> Observable<WSwriterReactor.State> {
        state.flatMap {[weak self] state -> Observable<State> in
            guard let self else{ return .just(state) }
            var st = state
            // 이건 수정할 때 적용되어야함
            if st.imageData == nil{
                st.isCreatable = false
                return .just(st)
            }
            st.isCreatable =
            self.isImageUploaded || (st.name != initialState.name) || (st.description != initialState.description)
            return .just(st)
        }
    }
    override func writerTransform(mutation: Observable<WSwriterReactor.Mutation>) -> Observable<WSwriterReactor.Mutation> {
        let res = provider.wsService.event.flatMap { event -> Observable<WSwriterReactor.Mutation> in
            switch event{
            case .edit(let wsResponse):
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
