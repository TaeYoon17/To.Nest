//
//  RCTable.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
protocol RCMTableAble: Object,Identifiable,RCMTableConvertable{
    var name:String { get set}
    var count: Int {get set}
}
typealias RCMTable = ReferenceCountManagerTable
// 실제 Realm에 담길 래퍼런스 카운트 테이블 구조
final class ReferenceCountManagerTable: Object,RCMTableAble{
    @Persisted(primaryKey: true) var name: String
    @Persisted var count: Int = 0
     
    required convenience init(fileName: String) {
        self.init()
        self.name = fileName
    }
    required convenience init(name fileName:String, count: Int) {
        self.init(fileName: fileName)
        self.count = count
    }
}
