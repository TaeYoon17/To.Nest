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
        case failed(ChannelFailed)
        case unreads([UnreadsResponse])
        case check(CHResponse)
        case channelUsers(id:Int,[UserResponse])
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
    func edit(channelName:String,_ info: CHInfo) {
        Task{
            do{
                let result = try await NM.shared.editCH(wsID: mainWS.id,name:channelName, info)
                Task{@BackgroundActor in
                    await repository.updateChannelName(channelID:result.channelID,name:result.name)
                }
                print("updateResult: \(result)")
                event.onNext(.update(result))
            }catch{
                
            }
        }
    }
    func check(title:String){
        Task{
            do{
                let response = try await NM.shared.checkCH(wsID: mainWS.id,channelName: title)
                event.onNext(.check(response))
                let users = try await NM.shared.checkCHUsers(wsID: mainWS.id, channelName: title)
                let channelID = response.channelID
                event.onNext(.channelUsers(id: channelID, users))
            }catch{
                print(error)
            }
        }
    }
    func checkUser(channelID:Int,title:String){
        Task{
            do{
                let users = try await NM.shared.checkCHUsers(wsID: mainWS.id, channelName: title)
                event.onNext(.channelUsers(id: channelID, users))
            }catch{
                print(error)
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
    func checkAll(){
        Task{
            do{
                let results:[CHResponse] = try await NM.shared.checkAllCH(wsID: mainWS.id)
                event.onNext(.all(results))
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
    func checkAllMy() {
        Task{
            do{
                print("checkAllMy mainWS \(mainWS)")
                let results = try await NM.shared.checkAllMyCH(wsID: mainWS.id)
                self.event.onNext(.allMy(results))
                // 해당 워크스페이스 아이디를 갖으면서
                // 기존에 없었던 테이블 생성... or 기존에 있었지만 받아온 채널아이디가 없는 테이블 삭제
                Task{@BackgroundActor in
                    for v in results{ // 채널 response
                        try await Task.sleep(for: .microseconds(10))
                        if let table = repository.getTableBy(tableID: v.channelID){
                            // 기존에 존재하는 채널... 업데이트 필요
                            await repository.updateChannelName(channelID: v.channelID, name: v.name)
                        }else{// 기존에 존재하지 않아서 새로 추가해야하는 채널
                            await repository.create(item: ChannelTable(channelInfo: v))
                        }
                    }
                    let exiseted = repository.getTasks.where { $0.wsID == self.mainWS.id}
                    let checkUnreads = Array(exiseted.map{ ($0.lastReadDate,$0.channelName) })
                    let existedChannels = exiseted.map{$0.channelID}
                    let removeChannelIDs = Set(existedChannels).subtracting(results.map{$0.channelID})
                    Task.detached {
                        var unreadsResponses: [UnreadsResponse] = []
                        for checks in checkUnreads{
                            do{
                                let unreads = try await self.updateChannelUnreads(channelName: checks.1,lastDate: checks.0)
                                unreadsResponses.append(unreads)
                            }catch{
                                print(error)
                                print("여기 에러")
                            }
                        }
                        let responses = unreadsResponses
                        print("unreadsResponses",responses)
                        await MainActor.run {
                            self.event.onNext(.unreads(responses))
                        }
                    }
                    repository.removeChannelTables(ids: Array(removeChannelIDs))
                }
            }catch{
                print("checkAllMy() 여기 에러")
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
    func updateChannelUnreads(channelName: String,lastDate:Date?) async throws -> UnreadsResponse{
        try await NM.shared.checkUnreads(wsID: mainWS.id, channelName: channelName, date: lastDate)
    }
    func authValidCheck(error: Error)->Bool{
        print(error)
        if let auth = error as? AuthFailed{
            switch auth{
            case .isValid: return true // 로그인 필요 X
            default: return false // 재로그인 로직 돌리기
            }
        }
        return true
    }
}
