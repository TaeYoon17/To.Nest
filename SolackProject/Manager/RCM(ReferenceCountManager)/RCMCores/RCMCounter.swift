//
//  RCCounter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift

import Foundation
import RealmSwift
typealias RCMAble = ReferenceCounterManagerAble
// 이 프로토콜을 준수하면 최소한의 래퍼런스 카운트 매니저 클래스 생성 가능
protocol ReferenceCounterManagerAble:AnyObject{
    associatedtype Item: RCMTableConvertable where Item.ID == String
    associatedtype Table: RCMTable
    typealias SnapShot = RCMSnapshot<Self,Item,Table>
    var repository : ReferenceRepository<Table> {get set}
    var instance: [Item.ID:Item] { get set }
    func plusCount(id: Item.ID) async
    func minusCount(id: Item.ID) async
    func saveRepository() async
    var snapshot:SnapShot{get}
    func apply(_ snapshot:SnapShot)
}

