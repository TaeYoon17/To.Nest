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
        }
    }
}
