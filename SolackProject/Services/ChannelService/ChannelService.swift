//
//  ChannelService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/23/24.
//

import Foundation
import RxSwift
import RealmSwift
typealias CHService = ChannelService
protocol ChannelProtocol{
    var event:PublishSubject<CHService.Event> {get}
    var transition: PublishSubject<CHService.Transition> { get }
    func create(_ info:CHInfo)
    func edit(channelName:String,_ info:CHInfo)
    func checkUser(channelID:Int,title:String)
    func checkAllMy()
    func checkAll()
    func check(title:String)
    func delete(channelID:Int,channelName:String)
    func changeAdmin(userID: Int,channelName: String)
    func exit(channelID:Int,channelName:String)
    func join(channelID:Int,channelName:String)
}
final class ChannelService:ChannelProtocol{
    @DefaultsState(\.mainWS) var mainWS
    let event = PublishSubject<Event>()
    let transition = PublishSubject<Transition>()
    @BackgroundActor var repository:ChannelRepository!
    @BackgroundActor var chChatrepository: ChannelChatRepository!
    @BackgroundActor var userRepository: UserInfoRepository!
    @BackgroundActor var imageReferenceCountManager: ImageRCM!
    @BackgroundActor var userReferenceCountManager: UserRCM!
    enum Event{
        case create(CHResponse)
        case allMy([CHResponse])
        case all([CHResponse])
        case update(CHResponse)
        case delete(chID:Int)
        case exit(chID:Int)
        case failed(ChannelFailed)
        case unreads([UnreadsChannelRes])
        case check(CHResponse)
        case channelUsers(id:Int,[UserResponse])
        case channelAdminChange(CHResponse)
        case join(chID:Int,channelName:String)
    }
    enum Transition{
        case goChatting(chID:Int,chName:String)
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
    func updateChannelUnreads(channelName: String,lastDate:Date?) async throws -> UnreadsChannelRes{
        try await NM.shared.checkUnreads(wsID: mainWS.id, channelName: channelName, date: lastDate)
    }
    func authValidCheck(error: Error)->Bool{
        print("ChannelService authValidCheck")
        if let auth = error as? AuthFailed{
            switch auth{
            case .isValid: return true // 로그인 필요 X
            default: return false // 재로그인 로직 돌리기
            }
        }
        return true
    }
}
// MARK: --  CRUD
extension ChannelService{
    func create(_ info: CHInfo){
        Task{
            do{
                let result:CHResponse = try await NM.shared.createCH(wsID: mainWS.id, info)
                await appendMyChannel(channelInfo: result)
                event.onNext(.create(result))
            }catch{
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let chError = error as? ChannelFailed{
                    event.onNext(.failed(chError))
                }
            }
        }
    }
    func delete(channelID:Int,channelName:String){
        Task{
            do{
                let response = try await NM.shared.deleteCH(wsID: mainWS.id, channelName: channelName)
                Task{ @BackgroundActor in
                    await deleteChannel(channelID:channelID)
                }
                if response{
                    event.onNext(.delete(chID:channelID))
                }
            }catch{
                print(error)
            }
        }
    }
    func edit(channelName:String,_ info: CHInfo) {
        Task{
            do{
                let result = try await NM.shared.editCH(wsID: mainWS.id,name:channelName, info)
                Task{@BackgroundActor in
                    await repository.updateChannelName(channelID:result.channelID,name:result.name)
                }
                event.onNext(.update(result))
            }catch{
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let chError = error as? ChannelFailed{
                    event.onNext(.failed(chError))
                }
            }
        }
    }
    func exit(channelID:Int,channelName:String){
        Task{
            do{
                let wsID = mainWS.id
                let res = try await NM.shared.exitCH(wsID: wsID, channelNmae: channelName)
                Task{ @BackgroundActor in
                    await deleteChannel(channelID:channelID)
                }
                self.event.onNext(.exit(chID: channelID))
            }catch{
                print("channelExit error")
                print(error)
            }
        }
    }
    func join(channelID:Int,channelName:String){
        Task{
            do{
                let wsID = mainWS.id
                _ = try await NM.shared.checkChat(wsID: wsID, chName: channelName, date: Date())
                await self._checkAllMy()
                self.event.onNext(.join(chID: channelID, channelName: channelName))
            }catch{
                print("channel join error")
                print(error)
            }
        }
    }
}

extension ChannelService{
    func changeAdmin(userID: Int,channelName: String){
        Task{
            do{
                let wsID = mainWS.id
                let res = try await NM.shared.changeCHAdmin(wsID: wsID, channelName: channelName, userID: userID)
                event.onNext(.channelAdminChange(res))
            }catch{
                print("changeAdmin Error \(error)")
            }
        }
    }
}
