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
    @Persisted(originProperty: "chatList") var parentSet: LinkingObjects<CHTable>
    @Persisted var chID: Int
    @Persisted var content: String?
    @Persisted var imagePathes: List<String> = .init()
    @Persisted var createdAt: Date
    @Persisted var userID: Int
    convenience init(chatID: Int, chID: Int, content: String?, imagePathes: [String], createdAt: Date, userID:Int) {
        self.init()
        self.chatID = chatID
        self.chID = chID
        self.parentSet = parentSet
        self.content = content
        imagePathes.forEach { self.imagePathes.append($0)}
        self.createdAt = createdAt
        self.userID = userID
    }
}
extension ChannelChatTable{
    convenience init(response info:ChatResponse) {
        self.init(chatID: info.chatID,
                  chID: info.channelID,
                  content: info.content,
                  imagePathes: info.files,
                  createdAt: info.createdAt.convertToDate(),
                  userID: info.user.userID)
    }
}
