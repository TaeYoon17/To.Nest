//
//  ReferenceCountable.swift
//  CardZip
//
//  Created by 김태윤 on 2023/11/09.
//

import Foundation
import RealmSwift
typealias RCMTableConvertable = ReferenceCountTableConvertable
// 이 프로토콜을 준수하면 래퍼런스 카운트 매니저용 [DB Table]로 변환 가능
// 래퍼런스 카운트 매니저 [DB Repository]에서 이 프로토콜을 준수한 인스턴스를 이용할 수 있음
protocol ReferenceCountTableConvertable:Identifiable{
    var id:String {get}
    var name: String {get}
    var count: Int {get set}
    init(name:String,count:Int)
}
extension RCMTableConvertable{
    var id:String{ name }
}
