//
//  WorkSpaceService+DB.swift
//  SolackProject
//
//  Created by 김태윤 on 2/6/24.
//

import Foundation
import RealmSwift
extension WorkSpaceService{
    @BackgroundActor func deleteAllDB(byWSId wsID:Int) async{
        let channelTasks = await self.channelRepository.getChannelsByWS(wsID: wsID)
        for channel in channelTasks{
            await deleteChannelData(channel: channel)
        }
        await imageReferenceCountManager.saveRepository()
        await userReferenceCountManager.saveRepository()
        channelRepository.removeChannelTables(ids: channelTasks.map{$0.channelID}, includeSubTables: true)
    }
    @BackgroundActor fileprivate func deleteChannelData(channel:ChannelTable)async{
        for chat in channel.chatList{
            await deleteChatData(chat: chat)
        }
    }
    @BackgroundActor fileprivate func deleteChatData(chat:ChannelChatTable)async {
        var imageRC = imageReferenceCountManager.snapshot
        var userRC = userReferenceCountManager.snapshot
        await userRC.minusCount(channelID: chat.chID, userID: chat.userID)
        for imagePath in chat.imagePathes{
            await imageRC.minusCount(id: imagePath)
        }
        imageReferenceCountManager.apply(imageRC)
        userReferenceCountManager.apply(userRC)
    }
    @BackgroundActor func updateUserProfile(responses:[UserResponse]) async {
        for var response in responses{
            guard let table = userRepository.getTableBy(tableID: response.userID),
                  table.profileImage != response.profileImage else {return}
            let newImageURL = response.profileImage
            if let prevProfileImage = table.profileImage,FileManager.checkExistDocument(fileName: prevProfileImage){
                FileManager.removeFromDocument(fileName: prevProfileImage)
            }
            if let newImageURL, let imageData = await NM.shared.getThumbnail(newImageURL){
                do{
                    try imageData.saveToDocument(fileName: newImageURL.webFileToDocFile())
                }catch{
                    print("updateUserProfile error",error)
                }
            }
            response.profileImage = response.profileImage?.webFileToDocFile()
            await userRepository.update(table: table, response: response)
        }
    }
}
