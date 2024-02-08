//
//  MSGSercie+DM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
extension MessageService{
    func openSocket(roomID: Int){
        do{
            try SocketManagerr.shared.openDMSocket(connect: .chat(channelID: roomID), delegate: self)
            Task{@BackgroundActor in
                await roomRepository.updateRoomReadDate(roomID: roomID)
            }
        }catch{
            print(error)
        }
    }
    func closeSocket(roomID:Int){
        
    }
    func create(roomID: Int, dmChat: ChatInfo) {
        Task{
            do{
                var ircSnapshot = await imageReferenceCountManager.snapshot
                var res:DMResponse = try await NM.shared.createDM(wsID: mainWS.id, roomID: roomID, info: dmChat)
                for (fileName,file) in zip(res.files,dmChat.files){
                    if !FileManager.checkExistDocument(fileName: fileName){
                        try file.file.saveToDocument(fileName: fileName)
                    }
                    await ircSnapshot.plusCount(id: fileName)
                }
                res.files = res.files.map{$0.webFileToDocFile()}
                res.user.profileImage = res.user.profileImage?.webFileToDocFile()
                let result = res
                let dmTable = DMChatTable(response: result)
                await dmChatRepository.create(item: dmTable)
                await roomRepository.appendChat(roomID: roomID, chatTables: [dmTable])
                try await appendUserReferenceCounts(roomID: roomID, createUsers: [result.user])
                try await updateUserInformationToDataBase(userIDs: [result.user.userID])
                print("DMcreateResult:",result)
                event.onNext(.create(response: .dm([result])))
            }catch{
                print("MessageService DM Error!!")
                print(error)
            }
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
        }
    }
    
    func receivedSocketData(result: Result<Data,Error>,roomID:Int){
        
    }
    func getDirectMessageDatas(roomID:Int,userID:Int){
        let wsID = mainWS.id
        Task{@BackgroundActor in
            await _getDirectMessageDatas(wsID: wsID,roomID:roomID,userID:userID)
        }
    }
    func fetchDirectMessageDB(userID:Int,roomID: Int){
        let wsID = mainWS.id
        Task{@BackgroundActor in
            await self._getDirectMessageDatas(wsID: wsID,roomID:roomID,userID:userID)
            guard let chatTablesList = self.roomRepository.getTableBy(tableID: roomID)?.chatList else {
                fatalError("존재하지 않는 채팅")
            }
            let allUsers = chatTablesList.map(\.userID).makeSet()
            try await updateUserInformationToDataBase(userIDs: allUsers)
            var dmResponses:[DMResponse] = []
            for chatTable in chatTablesList{
                guard let userTable = userRepository.getTableBy(userID: chatTable.userID) else {fatalError("존재하지 않는 유저 정보")}
                let userResponse = userTable.getResponse
                let chatResponse = chatTable.getResponse(userResponse: userResponse)
                dmResponses.append(chatResponse)
            }
            self.event.onNext(.check(response: .dm(dmResponses)))
        }
    }
}
fileprivate extension MessageService{
    @BackgroundActor func _getDirectMessageDatas(wsID:Int,roomID:Int,userID:Int) async{
        do{
            let lastCheckDate = self.roomRepository.getTableBy(tableID: roomID)?.lastCheckDate
            let dmChatsResponse:DMChatsResponse = try await NM.shared.checkDM(wsID: wsID, userID: userID, date: lastCheckDate)
            let chatResponses:[DMResponse] = dmChatsResponse.chats
            guard !chatResponses.isEmpty else {return}
            await roomRepository.updateRoomCheckDate(roomID: roomID)
            if let lastResponse = dmChatsResponse.chats.last{
                let text = lastResponse.content ?? "사진"
                await roomRepository.updateLastContent(roomID: roomID, text: text)
            }
            try await getResponses(responses: chatResponses, roomID: roomID)
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
            self.event.onNext(.check(response: .dm(chatResponses)))
        }catch{
            print("_getDirectMessageDatas")
            print(error)
        }
    }
    @BackgroundActor func getResponses(responses:[DMResponse],roomID:Int) async throws{
        await roomRepository.updateRoomCheckDate(roomID: roomID)
        let createResponses =  await responses.asyncFilter {// 이미 해당 채팅이 디비에 존재하지 않은 것만 가져온다. -> 채팅 내용 저장
            !self.dmChatRepository.isExistTable(dmID: $0.dmID)
        }
        try await appendChatResponseToDataBase(roomID: roomID, createResponses: createResponses)
        try await appendUserReferenceCounts(roomID: roomID, createUsers: createResponses.map(\.user))
        let allUsers = responses.map{$0.user.userID}.makeSet()
        try await updateUserInformationToDataBase(userIDs: allUsers)
    }
}
extension DMChatTable{
    func getResponse(userResponse: UserResponse) -> DMResponse{
        DMResponse(dmID: self.dmID, roomID: self.roomID, content: self.content, createdAt: self.createdAt.convertToString(), files: Array(self.imagePathes), user: userResponse)
    }
}
