//
//  ChannelRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
typealias CHRepository = ChannelRepository
@BackgroundActor final class ChannelRepository: TableRepository<CHTable>{
    var channelChatRepository :ChannelChatRepository!
    override init() async throws{
        try await super.init()
        self.channelChatRepository = try await ChannelChatRepository()
    }
    func getChannelsByWS(wsID: Int) async -> Results<CHTable>{
        return self.getTasks.where { table in
            table.wsID == wsID
        }
    }
    func updateChannelCheckDate(channelID:Int) async{
        if let table = self.getTableBy(tableID: channelID){
            try! await self.realm.asyncWrite({
                table.lastCheckDate = Date()
            })
        }
    }
    func updateChannelReadDate(channelID:Int) async{
        if let table = self.getTableBy(tableID: channelID){
            try! await self.realm.asyncWrite({
                table.lastReadDate = Date()
            })
        }
    }
    func updateChannelName(channelID:Int,name:String) async{
        if let table = self.getTableBy(tableID: channelID){
            try! await self.realm.asyncWrite({
                table.channelName = name
            })
        }
    }
    // 채널 테이블에 채팅 테이블 추가하기
    func appendChat(channelID:Int,chatTables:[CHChatTable]) async {
        guard let table = self.getTableBy(tableID: channelID) else {fatalError("Can't find channel table")}
        await appendChat(channelTable: table, chatTables: chatTables)
    }
    func appendChat(channelTable: ChannelTable,chatTables:[CHChatTable]) async {
        try! await self.realm.asyncWrite({
            channelTable.chatList.append(objectsIn: chatTables)
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
                channelChatRepository.deleteAllChatList(tables: tables)
            }
            Task{@BackgroundActor in
                try await realm.asyncWrite {
                    realm.delete(table)
                }
            }
        }
    }
}
