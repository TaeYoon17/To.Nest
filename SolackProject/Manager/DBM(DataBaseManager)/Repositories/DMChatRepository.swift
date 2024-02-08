//
//  DMChatRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 2/6/24.
//

import Foundation
import RealmSwift
@BackgroundActor final class DMChatRepository: TableRepository<DMChatTable>{
    func isExistTable(dmID: Int)-> Bool{
        self.getTableBy(tableID: dmID) != nil
    }
    func deleteAllChatList(tables:[DMChatTable]){
        Task{@BackgroundActor in
            try await realm.asyncWrite {
                realm.delete(tables)
            }
        }
    }
    func getAllChatList(dmID:Int)-> [DMChatTable]{
        let res:Results<DMChatTable> = self.getTasks.where { table in
            table.dmID == dmID
        }
        return Array(res)
    }
}
