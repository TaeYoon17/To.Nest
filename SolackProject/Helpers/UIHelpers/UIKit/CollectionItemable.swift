//
//  CollectionItemable.swift
//  SolackProject
//
//  Created by 김태윤 on 1/24/24.
//

import UIKit
protocol CollectionItemable:Hashable{
    associatedtype ItemType
    associatedtype SectionType
    var id:String { get }
    var itemType:ItemType { get }
    var sectionType:SectionType{get}
}
