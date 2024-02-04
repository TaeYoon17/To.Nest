//
//  DMService.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import RxSwift
import RealmSwift
protocol DMProtocol{
    var event:PublishSubject<DMService.Event> {get}
    func checkAll(wsID:Int)
}
final class DMService:DMProtocol{
    @DefaultsState(\.mainWS) var mainWS
    let event = PublishSubject<Event>()
    @BackgroundActor var repository:ChannelRepository!
    @BackgroundActor var chChatrepository: ChannelChatRepository!
    @BackgroundActor var userRepository: UserInfoRepository!
    @BackgroundActor var imageReferenceCountManager: ImageRCM!
    @BackgroundActor var userReferenceCountManager: UserRCM!
    enum Event{
        case allMy([DMResponse])
    }
    init(){
        Task{@BackgroundActor in
            repository = try await ChannelRepository()
            chChatrepository = try await ChannelChatRepository()
            userRepository = try await UserInfoRepository()
            userReferenceCountManager = UserRCM.shared
            imageReferenceCountManager = ImageRCM.shared
        }
    }
    
    func checkAll(wsID: Int) {
        Task{
            do{
                let responses:[DMResponse] = try await NM.shared.checkAllDM(wsID:wsID)
                event.onNext(.allMy(responses))
            }catch{
                print(error)
            }
        }
    }
}
