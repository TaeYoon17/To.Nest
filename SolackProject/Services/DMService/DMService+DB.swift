//
//  DMService+DB.swift
//  SolackProject
//
//  Created by 김태윤 on 2/7/24.
//

import Foundation
extension DMService{
    @BackgroundActor func appendMyRoom(roomID:Int,wsID:Int,userResponse:UserResponse) async {
        if nil == repository.getTableBy(tableID: roomID){
            await repository.create(item: DMRoomTable(roomID: roomID, wsID: wsID, userID: userResponse.userID, createdAt: Date.nowKorDate))
        }
    }
}
