//
//  RoomTable.swift
//  SolackProject
//
//  Created by 김태윤 on 2/6/24.
//

import Foundation
import RealmSwift
final class DMRoomTable:Object,Identifiable{
    @Persisted(primaryKey: true) var roomID: Int
    @Persisted var wsID: Int
    @Persisted var chatList: List<DMChatTable> = .init()
    @Persisted var userID:Int
    @Persisted var lastContent:String?
    @Persisted var lastReadDate:Date?
    @Persisted var lastCheckDate:Date?
    convenience init(roomID:Int,wsID:Int,userID:Int,createdAt:Date) {
        self.init()
        self.roomID = roomID
        self.wsID = wsID
        self.userID = userID
        lastReadDate = createdAt
        lastCheckDate = createdAt
    }
}
extension DMRoomTable{
//    convenience init(roomInfo info:DMRoomResponse) {
//        self.init(roomID: info.roomID,
//                  userName: info.user.nickname,
//                  wsID: info.workspaceID,userID: )
//    }
}
