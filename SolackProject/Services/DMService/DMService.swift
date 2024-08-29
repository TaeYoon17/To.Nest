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
    var transition: PublishSubject<DMService.Transition> {get}
    func checkAll(wsID:Int)
    func getRoomID(user:UserResponse)
}
final class DMService:DMProtocol{
    @DefaultsState(\.mainWS) var mainWS
    let event = PublishSubject<Event>()
    let transition = PublishSubject<Transition>()
    @BackgroundActor var repository:DMRoomRepository!
    @BackgroundActor var dmChatrepository: DMChatRepository!
    @BackgroundActor var userRepository: UserInfoRepository!
    @BackgroundActor var imageReferenceCountManager: ImageRCM!
    @BackgroundActor var userReferenceCountManager: UserRCM!
    enum Event{
        case allMy([DMRoomResponse])
        case dmRoomID(id:Int,userResponse:UserResponse)
        case unreads([UnreadDMRes])
    }
    enum Transition{
        case goDM(id:Int,userResponse:UserResponse)
    }
    init(){
        Task{@BackgroundActor in
            repository = try await DMRoomRepository()
            dmChatrepository = try await DMChatRepository()
            userRepository = try await UserInfoRepository()
            userReferenceCountManager = UserRCM.shared
            imageReferenceCountManager = ImageRCM.shared
        }
    }
    func checkAll(wsID: Int) { // DM 방 조회하기
        let wsID = mainWS.id
        Task{
            do{
                let responses:[DMRoomResponse] = try await NM.shared.checkAllRooms(wsID:wsID)
                Task{@BackgroundActor in
                    var sendResponses:[DMRoomResponse] = []
                    for var response in responses{
                        try await Task.sleep(for: .microseconds(10))
                        await updateDBRoomProfileImage(response: &response)
                        if let table = repository.getTableBy(tableID: response.roomID){
                            response.content = table.lastContent
                            response.lastDate = table.lastContentDate
                        }else{
                            await repository.create(item: DMRoomTable(roomID: response.roomID, wsID: response.workspaceID, userID: response.user.userID,createdAt: response.createdAt.convertToDate()))
                        }
                        sendResponses.append(response)
                    }
                    event.onNext(.allMy(sendResponses))
                    let existed = repository.getTasks.where{$0.wsID == self.mainWS.id}
                    let checkUnreads = Array(existed.map{($0.lastReadDate,$0.roomID)})
                    let existedRooms = existed.map{$0.roomID}
                    let removeRoomIDs = Set(existedRooms).subtracting(responses.map(\.roomID))
                    print(checkUnreads)
                    Task {
                        var unreadsResponses:[UnreadDMRes] = []
                        for checkUnread in checkUnreads{
                            do{
                                let unreads = try await self.updateDMUnreads(roomID: checkUnread.1, wsID: wsID, lastDate: checkUnread.0)
                                unreadsResponses.append(unreads)
                            }catch{
                                print("DM Unreads Error")
                                print(error)
                            }
                        }
                        let responses = unreadsResponses
                        await MainActor.run {
                            self.event.onNext(.unreads(responses))
                        }
                    }
                    repository.removeChannelTables(ids: Array(removeRoomIDs))
                }
            }catch{
                print("DMService checkAll")
                print(error)
            }
        }
    }
    func getRoomID(user:UserResponse){
        Task{
            do{
                let wsID = mainWS.id
                let response = try await NM.shared.checkDM(wsID: wsID, userID: user.userID, date: Date.nowKorDate)
                await appendMyRoom(roomID: response.roomID, wsID: response.workspaceID, userResponse: user)
                event.onNext(.dmRoomID(id: response.roomID,userResponse: user))
            }catch{
                print("DMService getRoomID")
                print(error)
            }
        }
    }
}
fileprivate extension DMService{
    func updateDMUnreads(roomID:Int,wsID:Int,lastDate:Date?) async throws -> UnreadDMRes{
        try await NM.shared.unreadDM(wsID: wsID, roomID: roomID, date: lastDate)
    }
}
