//
//  DMChatTransformMutation.swift
//  SolackProject
//
//  Created by 김태윤 on 2/8/24.
//

import Foundation
import RxSwift
import ReactorKit
extension DMChatReactor{
    var messageMutation: Observable<Mutation>{
        provider.msgService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            var mutations:[Observable<Mutation>] = []
            switch event{
            case .check(response: .dm(let response)):
                mutations.append(.just(.appendChat(.dbResponse(response))).throttle(.microseconds(200), scheduler: MainScheduler.instance))
                mutations.append(.just(.appendChat(nil)))
            case .create(response: .dm(let response)):
                mutations.append(.just(.appendChat(.create(response))).delay(.microseconds(200), scheduler: MainScheduler.instance))
                mutations.append(.just(.appendChat(nil)))
            case .socketReceive(response: .dm(let responses)):
                mutations.append(.just(.appendChat(.socketResponse(responses))).delay(.microseconds(200), scheduler: MainScheduler.instance))
                mutations.append(.just(.appendChat(nil)))
            default: break
            }
            return Observable.concat(mutations)
        }
    }
}
