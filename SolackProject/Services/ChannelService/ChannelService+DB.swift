//
//  ChannelService+DB.swift
//  SolackProject
//
//  Created by 김태윤 on 2/1/24.
//

import Foundation
extension ChannelService{
    @BackgroundActor func appendMyChannel(channelInfo: CHResponse) async {
        if nil == repository.getTableBy(tableID: channelInfo.channelID){
            await repository.create(item: ChannelTable(channelInfo: channelInfo))
        }
    }
    @BackgroundActor func deleteChannel(channelID: Int) async{
        var userSnapshot = userReferenceCountManager.snapshot
        var imageSnapshot = imageReferenceCountManager.snapshot
        guard let table = repository.getTableBy(tableID: channelID) else {return}
        let chatList = chChatrepository.getAllChatList(channelID: channelID)
        for chat in chatList{
            for imageName in chat.imagePathes{
                await imageSnapshot.minusCount(id: imageName)
            }
            await userSnapshot.minusCount(channelID: channelID, userID: chat.userID)
            await chChatrepository.delete(item: chat)
        }
        await repository.delete(item: table)
        userReferenceCountManager.apply(userSnapshot)
        imageReferenceCountManager.apply(imageSnapshot)
        await userReferenceCountManager.saveRepository()
        await imageReferenceCountManager.saveRepository()
    }
}
