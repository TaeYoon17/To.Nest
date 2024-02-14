//
//  MessageService+DB.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
import RealmSwift
import RxSwift
import UIKit
//MARK: -- 프로필 이미지 관련
extension MessageService{
    @BackgroundActor func updateUserInformationToDataBase(userIDs: any Collection<Int>) async throws{
        try await userIDs.asyncForEach { userID in
            var response = try await NM.shared.checkUser(userID: userID)
            try await Task.sleep(nanoseconds: 100)
            if let table:UserInfoTable = self.userRepository.getTableBy(userID: response.userID){
                if table.getResponse.profileImage == response.profileImage?.webFileToDocFile() && table.getResponse.nickname == response.nickname{return}
                // 프로필 이미지 업데이트
                response.profileImage = updateProfileImage(prevFilePath:table.profileImage,newImageWebPath:response.profileImage)
                await self.userRepository.update(table: table, response: response)
            }else{
                if let profileImage = response.profileImage{
                    try await saveProfileImageAsDocumentThumbnail(webPath: profileImage)
                }
                response.convertWebPathToFilePath()
                let table = UserInfoTable(userResponse: response)
                await self.userRepository.create(item: table)
            }
        }
    }
    func updateProfileImage(prevFilePath:String?,newImageWebPath:String?) -> String?{
        let newFilePath = newImageWebPath?.webFileToDocFile()
        guard prevFilePath != newFilePath else { return newFilePath}
        if let prevFilePath, FileManager.checkExistDocument(fileName: prevFilePath){
            FileManager.removeFromDocument(fileName: prevFilePath)
        }
        if let newImageWebPath{
            Task{ try await saveProfileImageAsDocumentThumbnail(webPath: newImageWebPath) }
        }
        return newFilePath
    }
    
    private func saveProfileImageAsDocumentThumbnail(webPath:String) async throws{
        let filePath = webPath.webFileToDocFile()
        guard let profileOriginalData = await NM.shared.getThumbnail(webPath) else { fatalError("Can't find profileThumbnail")}
        do{
            try profileOriginalData.saveToDocument(fileName: filePath)
        }catch{
            fatalError("이상해")
        }
    }
}
//MARK: -- Channel 관련
extension MessageService{
    func appendChatResponseToDataBase(channelID:Int,createResponses:[ChatResponse]) async throws{
        try await taskCounter.run(createResponses) {[weak self] res in // 채팅 이미지 썸네일 중 기존에 없던 것을 새로 저장한다.
            try await self?.saveChatImageAsDocumentThumbnail(response: res)
        }
        var ircSnapshot = await imageReferenceCountManager.snapshot
        var tables:[CHChatTable] = []
        for var res in createResponses{ // 채팅 이미지 썸네일 IRC 업데이트 및 채팅 테이블 추가
            res.convertWebPathToFilePath()
            await ircSnapshot.plusCount(ids: res.files)
            let chatTable = CHChatTable(response: res)
            await self.chChatrepository.create(item: chatTable)
            tables.append(chatTable)
        }
        await channelRepostory?.appendChat(channelID: channelID, chatTables: tables)
        await imageReferenceCountManager.apply(ircSnapshot)
    }
    func appendUserReferenceCounts(channelID:Int,createUsers: [UserResponse]) async throws{
        var userSnapshot = await self.userReferenceCountManager.snapshot
        await createUsers.asyncForEach { await userSnapshot.plusCount(channelID: channelID, userID: $0.userID) }
        await self.userReferenceCountManager.apply(userSnapshot)
    }
    private func saveChatImageAsDocumentThumbnail(response:ChatResponse) async throws{
        for webPath in response.files{
            let filePath = webPath.webFileToDocFile()
            guard let chatOriginalData = await NM.shared.getThumbnail(webPath) else { fatalError("Can't find chatThumbnail")}
            let chatThumbnailData = try UIImage.fetchBy(data: chatOriginalData, type: .messageThumbnail).imageData(maxMB: 1)
            if !FileManager.checkExistDocument(fileName: filePath){// 도큐먼트에 저장하지 않더라도 irc는 추가해야한다.
                try chatThumbnailData.saveToDocument(fileName: filePath)
            }
        }
    }
}
//MARK: -- DM 관련
extension MessageService{
    func appendChatResponseToDataBase(roomID:Int,createResponses:[DMResponse]) async throws{
        try await taskCounter.run(createResponses) {[weak self] res in // 채팅 이미지 썸네일 중 기존에 없던 것을 새로 저장한다.
            try await self?.saveDMImageAsDocumentThumbnail(response: res)
        }
        var ircSnapshot = await imageReferenceCountManager.snapshot
        var tables:[DMChatTable] = []
        // 채팅 이미지 썸네일 IRC 업데이트 및 채팅 테이블 추가
        for var res in createResponses where await dmChatRepository.getTableBy(tableID: res.dmID) == nil{
            res.convertWebPathToFilePath()
            await ircSnapshot.plusCount(ids: res.files)
            let chatTable = DMChatTable(response: res)
            await self.dmChatRepository.create(item: chatTable)
            tables.append(chatTable)
        }
        await roomRepository.appendChat(roomID: roomID, chatTables: tables)
        await imageReferenceCountManager.apply(ircSnapshot)
    }
    func appendUserReferenceCounts(roomID:Int,createUsers: [UserResponse]) async throws{
        var userSnapshot = await self.userReferenceCountManager.snapshot
        await createUsers.asyncForEach { await userSnapshot.plucCount(roomID: roomID, userID: $0.userID) }
        await self.userReferenceCountManager.apply(userSnapshot)
    }
    private func saveDMImageAsDocumentThumbnail(response:DMResponse) async throws{
        for webPath in response.files{
            let filePath = webPath.webFileToDocFile()
            guard let chatOriginalData = await NM.shared.getThumbnail(webPath) else { fatalError("Can't find chatThumbnail")}
            let chatThumbnailData = try UIImage.fetchBy(data: chatOriginalData, type: .messageThumbnail).imageData(maxMB: 1)
            if !FileManager.checkExistDocument(fileName: filePath){// 도큐먼트에 저장하지 않더라도 irc는 추가해야한다.
                try chatThumbnailData.saveToDocument(fileName: filePath)
            }
        }
    }
}
