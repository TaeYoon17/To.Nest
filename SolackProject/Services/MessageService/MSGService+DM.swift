//
//  MSGSercie+DM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
extension MessageService{
    func openSocket(roomID:Int){
        
    }
    func create(roomID: Int, dmChat: ChatInfo) {
        Task{
            do{
                var ircSnapshot = await imageReferenceCountManager.snapshot
                let res = try await NM.shared.createDM(wsID: mainWS.id, roomID: roomID, info: dmChat)
                for (fileName,file) in zip(res.files,dmChat.files){
                    if !FileManager.checkExistDocument(fileName: fileName){
                        try file.file.saveToDocument(fileName: fileName)
                    }
                    await ircSnapshot.plusCount(id: fileName)
                }
                let result = res
                event.onNext(.create(response: .dm([result])))
                let dmTable = DMChatTable(response: result)
                await dmChatRepository.create(item: dmTable)
                await roomRepository.appendChat(roomID: roomID, chatTables: [dmTable])
                try await appendUserReferenceCounts(roomID: roomID, createUsers: [result.user])
                try await updateUserInformationToDataBase(roomID: roomID, userIDs: [result.user.userID])
            }catch{
                print(error)
            }
            await imageReferenceCountManager.saveRepository()
            await userReferenceCountManager.saveRepository()
        }
    }
    func closeSocket(roomID:Int){
        
    }
    func receivedSocketData(result: Result<Data,Error>,roomID:Int){
        
    }
    func getDirectMessageDatas(roomID:Int){
        Task{@BackgroundActor in
//            let lastCheckDate =
        }
    }
    func fetchDirectMessageDB(roomID: Int){
        
    }
}

