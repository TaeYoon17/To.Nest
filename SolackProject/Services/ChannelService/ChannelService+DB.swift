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
}
