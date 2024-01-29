//
//  UserInfoRepository.swift
//  SolackProject
//
//  Created by 김태윤 on 1/28/24.
//

import Foundation
import RealmSwift
typealias UIRepository = UserInfoRepository
@BackgroundActor final class UserInfoRepository: TableRepository<UserInfoTable>{
    let imageRC = ImageRCM.shared
    
    
    func update(table: UserInfoTable,response: UserResponse)async{
        try! await self.realm.asyncWrite({
            table.email = response.email
            table.nickName = response.nickname
            table.profileImage = response.profileImage
        })
    }
    func getTableBy(userID:Int) -> UserInfoTable?{
        return self.getTableBy(tableID: userID)
    }
    func deleteUserIDs(_ ids: [Int]) async {
        var snapshot = imageRC.snapshot
        for id in ids{
            let table = self.getTableBy(tableID: id)!
            if let profileImage = table.profileImage{
                await snapshot.minusCount(id: profileImage)
            }
            await self.delete(item: table)
        }
        imageRC.apply(snapshot)
        await imageRC.saveRepository()
    }
}
