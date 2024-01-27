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
    @Persisted var createdAt: Date
    @Persisted var userInfo: UserInfoTable?
    convenience init(chatID: Int, chID: Int, parentSet: LinkingObjects<CHTable>, content: String, imagePathes: [String], createdAt: Date, userInfo: UserInfoTable? = nil) {
        self.init()
        self.chatID = chatID
        self.chID = chID
        self.parentSet = parentSet
        self.content = content
        self.imagePathes = .init()
        imagePathes.forEach { self.imagePathes.append($0)}
        self.createdAt = createdAt
        self.userInfo = userInfo
    }
}
