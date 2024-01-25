//
//  ChannelChatTable.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
typealias CHChatTable = ChannelChatTable
final class ChannelChatTable: Object,Identifiable{
    @Persisted(primaryKey: true) var chatID: Int
    @Persisted var chID: Int
    @Persisted(originProperty: "chatList") var parentSet: LinkingObjects<CHTable>
    @Persisted var content: String
    @Persisted var imagePathes: List<String>
    @Persisted var userInfo: UserInfoTable
}
