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
    func checkAllMy()
    func checkAll()
    func check(title:String)
}
final class ChannelService:ChannelProtocol{
    @DefaultsState(\.mainWS) var mainWS
    let event = PublishSubject<Event>()
    let transition = PublishSubject<Transition>()
    @BackgroundActor var repository:ChannelRepository!
    enum Event{
        case create(CHResponse)
        case allMy([CHResponse])
        case all([CHResponse])
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
        }
    }
    func create(_ info: CHInfo){
        Task{
            do{
                let result:CHResponse = try await NM.shared.createCH(wsID: mainWS, info)
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
    func check(title:String){
        Task{
            do{
                let response = try await NM.shared.checkCH(wsID: mainWS,channelName: title)
                event.onNext(.check(response))
                let users = try await NM.shared.checkCHUsers(wsID: mainWS, channelName: title)
                let channelID = response.channelID
                event.onNext(.channelUsers(id: channelID, users))
            }catch{
                print(error)
            }
        }
    }
    func checkAll(){
        Task{
            do{
                let results:[CHResponse] = try await NM.shared.checkAllCH(wsID: mainWS)
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
                let results = try await NM.shared.checkAllMyCH(wsID: mainWS)
                self.event.onNext(.allMy(results))
                // 해당 워크스페이스 아이디를 갖으면서
                // 기존에 없었던 테이블 생성... or 기존에 있었지만 받아온 채널아이디가 없는 테이블 삭제
                Task{@BackgroundActor in
                    let exiseted = repository.getTasks.where { $0.wsID == self.mainWS}
                    
                    let checkUnreads = Array(exiseted.map{ ($0.lastReadDate,$0.channelName) })
                    print("여기도 가라 \(checkUnreads)")
                    
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
                        await MainActor.run {
                            self.event.onNext(.unreads(responses))
                        }
                    }
                    
                    for v in results{ // 채널 response
                        // 기존에 존재하지 않아서 새로 추가해야하는 채널
                        if nil == repository.getTableBy(tableID: v.channelID){
                            await repository.create(item: ChannelTable(channelInfo: v))
                        }
                    }
                    
                    let existedChannels = exiseted.map{$0.channelID}
                    let removeChannelIDs = Set(existedChannels).subtracting(results.map{$0.channelID})
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
        try await NM.shared.checkUnreads(wsID: mainWS, channelName: channelName, date: lastDate)
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
