//
//  ChatService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/27/24.
//

import Foundation
import RxSwift
typealias MSGService = MessageService
protocol MessageProtocol{
    var event:PublishSubject<MSGService.Event> {get}
    func create(chID:Int,chName:String,chat: ChatInfo)
    func create(dm: ChatInfo)
}
final class MessageService:MessageProtocol{
    @DefaultsState(\.mainWS) var mainWS
    @DefaultsState(\.userID) var userID
    var event = PublishSubject<MSGService.Event>()
    @BackgroundActor var channelRepostory: ChannelRepository!
    @BackgroundActor var chChatrepository: ChannelChatRepository!
    @BackgroundActor var userRepository: UserInfoRepository!
    @BackgroundActor var imageReferenceCountManager: ImageRCM!
    @BackgroundActor var userReferenceCountManager: UserRCM!
    var taskCounter:TaskCounter = .init()
    init(){
        Task{@BackgroundActor in
            channelRepostory = try await ChannelRepository()
            chChatrepository = try await ChannelChatRepository()
            userRepository = try await UserInfoRepository()
            imageReferenceCountManager = ImageRCM.shared
            userReferenceCountManager = UserRCM.shared
        }
    }
    enum Event{
        case create(response:ChatResponse)
    }
    
    
    func create(dm: ChatInfo){
        
    }
}
//MARK: -- Chat관련 서비스
extension MessageService{
    func create(chID:Int,chName:String,chat: ChatInfo){
        Task{
            var ircSnapshot = await imageReferenceCountManager.snapshot
            do{
                var res:ChatResponse = try await NM.shared.createChat(wsID:mainWS,chName: chName,info: chat)
                res.files = res.files.map{$0.webFileToDocFile()}
                // 파일 데이터 저장하기
                for (fileName, file) in zip(res.files,chat.files){
                    if !FileManager.checkExistDocument(fileName: fileName, type: file.type){
                        try file.file.saveToDocument(fileName: fileName)
                    }
                    await ircSnapshot.plusCount(id: fileName)
                }
                let result = res
                event.onNext(.create(response: result))
                try await self.userSave(channelID: chID, userResponse: result.user)
                Task {@BackgroundActor [weak self] in
                    let chatTable = CHChatTable(response: result)
                    await _ = self?.chChatrepository.create(item: chatTable)
                    await self?.channelRepostory.appendChat(channelID: chID, chatTables: [chatTable])
                }
            }catch{
                print(error)
            }
            await imageReferenceCountManager.apply(ircSnapshot)
            await imageReferenceCountManager.saveRepository()
        }
    }
    
    private func userSave(channelID:Int,userResponse:UserResponse) async throws {
        var ircSnapshot = await imageReferenceCountManager.snapshot
        var userrcSnapshot = await userReferenceCountManager.snapshot
        var response = userResponse
        let urlPath = response.profileImage
        let filePath = response.profileImage?.webFileToDocFile()
        response.profileImage = filePath
        defer{
            print("Defer가 일어난다")
            let (i,u) = (ircSnapshot,userrcSnapshot)
            Task{@BackgroundActor in
                imageReferenceCountManager.apply(i)
                userReferenceCountManager.apply(u)
                await imageReferenceCountManager.saveRepository()
                await userReferenceCountManager.saveRepository()
            }
        }
        if let userTable = await userRepository.getTableBy(tableID: userResponse.userID){ // 기존에 있던 유저, 업데이트 해야할 수 있음
            guard userTable.response != response else {
                await userrcSnapshot.plusCount(channelID: channelID, userID: userResponse.userID)
                return
            }
            guard userTable.profileImage != response.profileImage else {
                await userRepository.update(table: userTable, response: response)
                await userrcSnapshot.plusCount(channelID: channelID, userID: userResponse.userID)
                return
            }
            if let prevImageID = userTable.profileImage{ // 이전 이미지 없애기
                FileManager.removeFromDocument(fileName: prevImageID)
                await ircSnapshot.minusCount(id: prevImageID)
            }
            if let urlPath,let filePath,let profileImageData = await NM.shared.getThumbnail(urlPath){ // 프로필 이미지가 변경됨
                try profileImageData.saveToDocument(fileName: filePath)
                await ircSnapshot.plusCount(id: filePath)
            }
            await userRepository.update(table: userTable, response: response)
            await userrcSnapshot.plusCount(channelID: channelID, userID: userResponse.userID)
            return
        }else{
            // 기존에 없던 유저 반환 값, 새로 만들어야함
            if let urlPath,let filePath,let profileImageData = await NM.shared.getThumbnail(urlPath){ // 프로필 이미지가 추가
                try profileImageData.saveToDocument(fileName: filePath)
                await ircSnapshot.plusCount(id: filePath)
            }
            let userTable:UserInfoTable = UserInfoTable(userResponse: response)
            _ = await userRepository.create(item: userTable)
            await userrcSnapshot.plusCount(channelID: channelID, userID: userResponse.userID)
            return
        }
//        let (i,u) = (ircSnapshot,userrcSnapshot)
//        Task{@BackgroundActor in
//            imageReferenceCountManager.apply(i)
//            userReferenceCountManager.apply(u)
//            await imageReferenceCountManager.saveRepository()
//            await userReferenceCountManager.saveRepository()
//        }
    }
    
    func getChannelDatas(chID:Int,chName:String,date:Date? = nil){
        Task{
            var ircSnapshot = await imageReferenceCountManager.snapshot
            do{
                var res:[ChatResponse] = try await NM.shared.checkChat(wsID: mainWS, chName: chName, date: date)
            }catch{
                
            }
        }
    }
}
extension Data{
    func saveToDocument(fileName:String) throws{
        //1. 도큐먼트 경로 찾기
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDir.appendingPathComponent(fileName)
        try self.write(to: fileURL)
    }
}
extension UserInfoTable{
    var response:UserResponse{
        UserResponse(userID: self.userID, email: self.email, nickname: self.nickName, profileImage: self.profileImage)
    }
}
//var userID: Int
//var email: String
//var nickname: String
//var profileImage: String?
