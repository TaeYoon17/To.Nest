//
//  RCMSnapshot.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
// 래퍼런스 카운트 매니저에 변경 사항을 적용하기 위한 스냅샷... 다른 매니저라도 공통된 스냅샷 로직을 갖는다...
struct RCMSnapshot<RCM:RCMAble,Item:RCMTableConvertable,Table:RCMTableAble> where RCM.Item == Item, RCM.Table == Table,Item.ID == String
{
    var instance: [Item.ID : Item] = [:]
    init(irc: RCM){
        instance = irc.instance
    }
    func existItem(id: Item.ID) -> Bool{
        instance[id] != nil
    }
    mutating func plusCount(ids: [Item.ID]) async {
        for id in ids{
            await self.plusCount(id: id)
        }
    }
    mutating func plusCount(id: Item.ID) async {
        if instance[id] == nil{
            instance[id] = Item(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    mutating func minusCount(id: Item.ID)async {
        instance[id]?.count -= 1
    }
}
