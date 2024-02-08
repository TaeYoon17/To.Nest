//
//  DMRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 2/6/24.
//

import Foundation
import RealmSwift
@BackgroundActor final class DMRoomRepository: TableRepository<DMRoomTable>{
    var dmChatRepository :DMChatRepository!
    override init() async throws{
        try await super.init()
        self.dmChatRepository = try await DMChatRepository()
    }
    func updateLastContent(roomID:Int,text:String,date:Date) async{
        if let table = self.getTableBy(tableID: roomID){
            try! await self.realm.asyncWrite({
                table.lastContent = text
                table.lastContentDate = date
            })
        }
    }
    func updateRoomCheckDate(roomID:Int) async{
        if let table = self.getTableBy(tableID: roomID){
            try! await self.realm.asyncWrite({
                table.lastCheckDate = Date()
            })
        }
    }
    func updateRoomReadDate(roomID:Int) async{
        if let table = self.getTableBy(tableID: roomID){
            try! await self.realm.asyncWrite({
                table.lastReadDate = Date()
            })
        }
    }
//    func updateRoomName(channelID:Int,name:String) async{
//        if let table = self.getTableBy(tableID: channelID){
//            try! await self.realm.asyncWrite({
//                table.channelName = name
//            })
//        }
//    }
    // 채널 테이블에 채팅 테이블 추가하기
    func appendChat(roomID:Int,chatTables:[DMChatTable]) async {
        guard let table = self.getTableBy(tableID: roomID) else {fatalError("Can't find channel table")}
        await appendChat(roomTable: table, chatTables: chatTables)
    }
    func appendChat(roomTable: DMRoomTable,chatTables:[DMChatTable]) async {
        try! await self.realm.asyncWrite({
            roomTable.chatList.append(objectsIn: chatTables)
        })
    }
    // 하위 테이블 삭제를 기본 false로 함...
    func removeChannelTables(ids:[Int],includeSubTables: Bool = false){
        for v in ids{
            let table = getTableBy(tableID: v)
            guard let table else {
                fatalError("삭제할 테이블을 못 찾음")
            }
            if includeSubTables{
                let tables = Array(table.chatList)
                dmChatRepository.deleteAllChatList(tables: tables)
            }
        }
    }
}
