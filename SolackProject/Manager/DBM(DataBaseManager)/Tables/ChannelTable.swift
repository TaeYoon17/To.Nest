//
//  ChannelTable.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
typealias CHTable = ChannelTable
final class ChannelTable:Object,Identifiable{
    @Persisted(primaryKey: true) var channelID: Int
    @Persisted var wsID: Int
    @Persisted var chatList: List<ChannelChatTable> = .init()
    @Persisted var channelName:String
    @Persisted var lastReadDate:Date?
    @Persisted var lastCheckDate:Date?
    convenience init(channelID:Int,channelName:String,wsID:Int) {
        self.init()
        self.channelID = channelID
        self.channelName = channelName
        self.wsID = wsID
    }
}
extension ChannelTable{
    convenience init(channelInfo info:CHResponse) {
        self.init(channelID: info.channelID, channelName: info.name, wsID: info.workspaceID)
    }
}
