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
        case .create:
            print(wsInfo)
            provider.wsService.requestCreate(wsInfo)
            return Observable.concat([.just(.isLoading(true))])
        case .imageData(let data):
            self.wsInfo.image = data
            print("이미지 받아오기!!")
            return Observable.concat([])
        }
    }

}
