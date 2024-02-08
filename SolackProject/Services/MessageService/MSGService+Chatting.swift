//
//  MSGService+Chatting.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
//MARK: -- Chat관련 서비스
extension MessageService:SocketReceivable{
    func openSocket(channelID: Int){
        do{
            try SocketManagerr.shared.openSocket(connect: .chat(channelID: channelID), delegate: self)
            Task{@BackgroundActor in
                await channelRepostory.updateChannelReadDate(channelID: channelID)
            }
        }catch{
            print(error)
        }
    }
    func closeSocket(channelID: Int){
        SocketManagerr.shared.closeChatSocket()
        Task{@BackgroundActor in
            await channelRepostory.updateChannelReadDate(channelID: channelID)
        }
    }
    func receivedSocketData(result: Result<Data,Error>,channelID: Int) {
        do{
            switch result{
            case .success(let data):
                let responseData = try JSONDecoder().decode(ChatResponse.self, from: data)
                Task{@BackgroundActor in
                    do{
                        try await Task.sleep(for: .milliseconds(100))
                        await channelRepostory.updateChannelReadDate(channelID: channelID)
                        try await getResponses(responses: [responseData], channelID: channelID)
                        Task{
                            var response = responseData
                            response.files = response.files.map{$0.webFileToDocFile()}
                            response.user.profileImage = response.user.profileImage?.webFileToDocFile()
                            self.event.onNext(.socketReceive(response: .channel([response])))
                        }
                    }catch{
                        print(error)
                    }
                    await imageReferenceCountManager.saveRepository()
                    await userReferenceCountManager.saveRepository()
                }
            case .failure(let error): throw error
            }
        }catch{
            print(error)
        }
    }
    func create(chID:Int,chName:String,chat: ChatInfo){
        Task{
            do{
                var ircSnapshot = await imageReferenceCountManager.snapshot
                var res:ChatResponse = try await NM.shared.createChat(wsID:mainWS.id,chName: chName,info: chat)
                for (fileName, file) in zip(res.files,chat.files){// 파일 데이터 저장하기
                    if !FileManager.checkExistDocument(fileName: fileName.webFileToDocFile()){ try file.file.saveToDocument(fileName: fileName) }
                    await ircSnapshot.plusCount(id: fileName)
                }
                res.files = res.files.map{$0.webFileToDocFile()}
                res.user.profileImage = res.user.profileImage?.webFileToDocFile()
                let result = res
                let chatTable = CHChatTable(response: result)
                await chChatrepository.create(item: chatTable)
                await channelRepostory.appendChat(channelID: chID, chatTables: [chatTable])
                try await appendUserReferenceCounts(channelID: chID, createUsers: [result.user])
                try await updateUserInformationToDataBase(userIDs: [result.user.userID])
                event.onNext(.create(response: .channel([result])))
            }catch{
                print(error)
            }
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
        }
    }
    func getChannelDatas(chID:Int,chName:String){
        Task{@BackgroundActor in
            await _getChannelDatas(chID:chID,chName:chName)
        }
    }
    func fetchChannelDB(channelID:Int,channelName:String){
        Task{@BackgroundActor in
            await self._getChannelDatas(chID: channelID, chName: channelName)
            guard let chatTablesLists = channelRepostory.getTableBy(tableID: channelID)?.chatList else{
                fatalError("존재하지 않는 채팅")
            }
            let allUsers = chatTablesLists.map{$0.userID}.makeSet()
            try await updateUserInformationToDataBase(userIDs: allUsers)
            var chResponses:[ChatResponse] = []
            for chatTable in chatTablesLists{
                guard let userTable = userRepository.getTableBy(userID: chatTable.userID) else {fatalError("존재하지 않는 유저 정보")}
                let userResponse = userTable.getResponse
                let chatResponse = chatTable.getResponse(userResponse: userResponse)
                chResponses.append(chatResponse)
            }
            self.event.onNext(.check(response: .channel(chResponses)))
        }
    }
}
fileprivate extension MessageService{
    @BackgroundActor func _getChannelDatas(chID:Int,chName:String) async {
        do{
            let lastCheckDate = self.channelRepostory.getTableBy(tableID: chID)?.lastCheckDate
            let responses:[ChatResponse] = try await NM.shared.checkChat(wsID: mainWS.id, chName: chName, date: lastCheckDate)
            guard !responses.isEmpty else {return}
            try await getResponses(responses: responses, channelID: chID)
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
        }catch{
            print("_getChannelDatasError!!")
            print(error)
        }
    }
    @BackgroundActor func getResponses(responses:[ChatResponse],channelID chID: Int) async throws{
        await channelRepostory?.updateChannelCheckDate(channelID: chID)
        let createResponses =  await responses.asyncFilter {// 이미 해당 채팅이 디비에 존재하지 않은 것만 가져온다. -> 채팅 내용 저장
            !self.chChatrepository.isExistTable(chatID: $0.chatID)
        }
        // 0. 새로운 채팅 내역 저장
        try await appendChatResponseToDataBase(channelID:chID,createResponses: createResponses)
        // 1. 새로운 채팅 내역의 유저 참조 계수 업데이트 혹은 새로 생성
        try await appendUserReferenceCounts(channelID: chID, createUsers: createResponses.map(\.user))
        // 2. 유저 프로필 업데이트 진행 -- 모든 response의 유저 중 한 개씩만 존재하면 된다.
        let allUsers = responses.map{$0.user.userID}.makeSet()
        try await updateUserInformationToDataBase(userIDs: allUsers)
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
