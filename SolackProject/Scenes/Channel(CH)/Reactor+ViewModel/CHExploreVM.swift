//
//  CHExploreVM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/23/24.
//

import Foundation
import RxSwift
enum CHExploreAlert{
    case join(chID:Int,chName:String)
}
final class CHExploreVM{
    var provider:ServiceProviderProtocol!
    var disposeBag = DisposeBag()
    let allChannels: BehaviorSubject<[CHResponse]> = .init(value: [])
    let myChannels: BehaviorSubject<[CHResponse]> = .init(value: [])
    let alerts: PublishSubject<CHExploreAlert> = .init()
    let moveChatting: PublishSubject<(chID:Int,chName:String)> = .init()
    init(provider: ServiceProviderProtocol!,myChannels:[CHResponse]?) {
        self.provider = provider
        provider.chService.checkAll()
        if let myChannels{ self.myChannels.onNext(myChannels)}
        binding()
    }
    func binding(){
        provider.chService.event.bind(with: self) { owner, event in
            switch event{
            case .all(let response):
                owner.allChannels.onNext(response)
            default: break
            }
        }.disposed(by: disposeBag)
        moveChatting.bind(with: self) { owner, ch in
            owner.provider.chService.transition.onNext(.goChatting(chID: ch.chID, chName: ch.chName))
        }.disposed(by: disposeBag)
    }
}
