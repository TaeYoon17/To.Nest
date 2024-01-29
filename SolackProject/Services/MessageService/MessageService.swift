//
//  ChatService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/27/24.
//

import Foundation
import RxSwift
import UIKit
typealias MSGService = MessageService
protocol MessageProtocol{
    var event:PublishSubject<MSGService.Event> {get}
    func create(chID:Int,chName:String,chat: ChatInfo)
    func create(dm: ChatInfo)
    func getChannelDatas(chID:Int,chName:String)
}
final class MessageService:MessageProtocol{
    @DefaultsState(\.mainWS) var mainWS
    @DefaultsState(\.userID) var userID
    var event = PublishSubject<MSGService.Event>()
    @BackgroundActor var channelRepostory: ChannelRepository?
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
        case check(response:[ChatResponse])
    }
    
    
    func create(dm: ChatInfo){
        
    }
}
//MARK: -- Chat관련 서비스
extension MessageService{
    func create(chID:Int,chName:String,chat: ChatInfo){
        Task{
            do{
                var ircSnapshot = await imageReferenceCountManager.snapshot
                var res:ChatResponse = try await NM.shared.createChat(wsID:mainWS,chName: chName,info: chat)
                for (fileName, file) in zip(res.files,chat.files){// 파일 데이터 저장하기
                    if !FileManager.checkExistDocument(fileName: fileName){ try file.file.saveToDocument(fileName: fileName) }
                    await ircSnapshot.plusCount(id: fileName)
                }
                let result = res
                event.onNext(.create(response: result))
                let chatTable = CHChatTable(response: result)
                await chChatrepository.create(item: chatTable)
                await channelRepostory?.appendChat(channelID: chID, chatTables: [chatTable])
                try await appendUserReferenceCounts(channelID: chID, createUsers: [result.user])
                try await updateUserInformationToDataBase(channelID: chID, userResponses: [result.user])
            }catch{
                print(error)
            }
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
        }
    }
    func getChannelDatas(chID:Int,chName:String ){
        Task{
            do{
                let lastCheckDate = await self.channelRepostory?.getTableBy(tableID: chID)?.lastCheckDate
                let responses:[ChatResponse] = try await NM.shared.checkChat(wsID: mainWS, chName: chName, date: lastCheckDate)
                await channelRepostory?.updateChannelCheckDate(channelID: chID)
                let createResponses =  await responses.asyncFilter {// 이미 해당 채팅이 디비에 존재하지 않은 것만 가져온다. -> 채팅 내용 저장
                    await !self.chChatrepository.isExistTable(chatID: $0.chatID)
                }
                // 0. 새로운 채팅 내역 저장
                try await appendChatResponseToDataBase(channelID:chID,createResponses: createResponses)
                // 1. 새로운 채팅 내역의 유저 참조 계수 업데이트 혹은 새로 생성
                try await appendUserReferenceCounts(channelID: chID, createUsers: createResponses.map(\.user))
                // 2. 유저 프로필 업데이트 진행 -- 모든 response의 유저 중 한 개씩만 존재하면 된다.
                let allUsers = responses.map(\.user).makeSet()
                try await updateUserInformationToDataBase(channelID: chID, userResponses: allUsers)
            }catch{
                print(error)
            }
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
        }
    }
    
}

extension UserInfoTable{
    var getResponse:UserResponse{
        UserResponse(userID: self.userID, email: self.email, nickname: self.nickName, profileImage: self.profileImage)
    }
}
