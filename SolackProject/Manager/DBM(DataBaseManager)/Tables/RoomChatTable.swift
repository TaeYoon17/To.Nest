//
//  RoomChatTable.swift
//  SolackProject
//
//  Created by 김태윤 on 2/6/24.
//

import Foundation
import RealmSwift
final class DMChatTable: Object,Identifiable{
    @Persisted(primaryKey: true) var dmID: Int
    @Persisted(originProperty: "chatList") var parentSet: LinkingObjects<DMRoomTable>
    @Persisted var roomID:Int?
    @Persisted var userID: Int
    @Persisted var userName:String?
    @Persisted var content: String?
    @Persisted var imagePathes: List<String> = .init()
    @Persisted var createdAt: Date
    convenience init(dmID: Int,roomID:Int?, userID: Int, userName: String? = nil, content: String? = nil, imagePathes: [String], createdAt: Date) {
        self.init()
        self.dmID = dmID
        self.roomID = roomID
        self.parentSet = parentSet
        self.userID = userID
        self.userName = userName
        self.content = content
        imagePathes.forEach { self.imagePathes.append($0) }
        self.createdAt = createdAt
    }
}
extension DMChatTable{
    convenience init(response info:DMResponse) {
        self.init(dmID: info.dmID, roomID: info.roomID, userID: info.user.userID,
                  userName: info.user.nickname,content: info.content, imagePathes: info.files, createdAt: info.createdAt.convertToDate())
    }
}
