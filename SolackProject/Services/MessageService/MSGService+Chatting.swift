//
//  MSGService+Chatting.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
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
                await channelRepostory.appendChat(channelID: chID, chatTables: [chatTable])
                try await appendUserReferenceCounts(channelID: chID, createUsers: [result.user])
                try await updateUserInformationToDataBase(channelID: chID, userResponses: [result.user])
            }catch{
                print(error)
            }
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
        }
    }
    func getChannelDatas(chID:Int,chName:String){
        Task{@BackgroundActor in
            do{
                let lastCheckDate = self.channelRepostory.getTableBy(tableID: chID)?.lastCheckDate
                let responses:[ChatResponse] = try await NM.shared.checkChat(wsID: mainWS, chName: chName, date: lastCheckDate)
                await channelRepostory?.updateChannelCheckDate(channelID: chID)
                let createResponses =  await responses.asyncFilter {// 이미 해당 채팅이 디비에 존재하지 않은 것만 가져온다. -> 채팅 내용 저장
                    !self.chChatrepository.isExistTable(chatID: $0.chatID)
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
    func fetchChannelDB(channelID:Int){
        Task{@BackgroundActor in
            guard let chatTablesLists = channelRepostory.getTableBy(tableID: channelID)?.chatList else{
                fatalError("존재하지 않는 채팅")
            }
            var chResponses:[ChatResponse] = []
            for chatTable in chatTablesLists{
                guard let userTable = userRepository.getTableBy(userID: userID) else {fatalError("존재하지 않는 유저 정보")}
                let userResponse = userTable.getResponse
                let chatResponse = chatTable.getResponse(userResponse: userResponse)
                chResponses.append(chatResponse)
            }
            print(chResponses)
            self.event.onNext(.check(response: chResponses))
        }
    }
}
extension UserInfoTable{
    var getResponse:UserResponse{
        UserResponse(userID: self.userID, email: self.email, nickname: self.nickName, profileImage: self.profileImage)
    }
}
extension CHChatTable{
    func getResponse(userResponse: UserResponse) -> ChatResponse{
        ChatResponse(channelID: self.chatID, channelName:self.channelName ?? "", chatID: self.chatID, content: self.content, createdAt: self.createdAt.convertToString(), files: Array(self.imagePathes), user: userResponse)
    }
}
