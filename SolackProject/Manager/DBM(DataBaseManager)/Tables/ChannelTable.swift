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
    @Persisted var chatList: List<ChannelChatTable>
}
