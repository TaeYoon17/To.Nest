//
//  ChannelChatRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
typealias CHChatRepository = ChannelChatRepository
@BackgroundActor final class ChannelChatRepository: TableRepository<CHChatTable>{
    func deleteAllChatList(tables:[CHChatTable]){
        Task{@BackgroundActor in
            try await realm.asyncWrite {
                realm.delete(tables)
            }
        }
    }
    func getAllChatList(channelID:Int)-> [CHChatTable]{
        let res:Results<CHChatTable> = self.getTasks.where { table in
            table.chID == channelID
        }
        return Array(res)
    }
}
