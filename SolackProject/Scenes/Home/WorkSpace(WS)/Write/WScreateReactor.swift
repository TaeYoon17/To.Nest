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
    var workSpace = WorkSpace()
    override func mutate(action: WSwriterReactor.Action) -> Observable<WSwriterReactor.Mutation> {
        switch action{
        case .setDescription(let str):
            
            self.workSpace.description = str
            return Observable.concat([
                .just(Mutation.setDescription(str))
            ])
        case .setName(let str):
            let newStr:String = str.count > 30 ? String(str.prefix(30)) : str
            self.workSpace.name = str
            return Observable.concat([.just(.setName(str)),
                                      .just(Mutation.isCreatable(!str.isEmpty))
            ])
        case .create:
            return Observable.concat([])
        }
    }
}
