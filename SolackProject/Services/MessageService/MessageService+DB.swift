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
    @BackgroundActor func updateUserInformationToDataBase(channelID:Int,userResponses: any Collection<UserResponse>) async throws{
        try await userResponses.asyncForEach { response in
            var response = response
            if let table:UserInfoTable = self.userRepository.getTableBy(userID: response.userID){
                if table.getResponse == response {return}
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
        if let prevFilePath{
            if !FileManager.checkExistDocument(fileName: prevFilePath){
                FileManager.removeFromDocument(fileName: prevFilePath)
            }
        }
        if let newImageWebPath{
            Task{ try await saveProfileImageAsDocumentThumbnail(webPath: newImageWebPath) }
        }
        return newFilePath
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
    private func saveProfileImageAsDocumentThumbnail(webPath:String) async throws{
        let filePath = webPath.webFileToDocFile()
        guard let profileOriginalData = await NM.shared.getThumbnail(webPath) else { fatalError("Can't find profileThumbnail")}
        try profileOriginalData.saveToDocument(fileName: filePath)
    }
}
