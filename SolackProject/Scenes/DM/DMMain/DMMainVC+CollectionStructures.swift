//
//  DMMainVC+CollectionStructures.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
extension DMMainVC{
    enum SectionType:String{
        case member
        case dm
        static func getByNumber(_ num:Int) -> Self?{
            switch num{
            case 0: .member
            case 1: .dm
            default: nil
            }
        }
    }
    struct Item:Identifiable,Hashable{
        var id:String
        var sectionType:SectionType
        init(memberItem:MemberItem){
            self.id = memberItem.id
            self.sectionType = .member
        }
        init(dmItem:DMItem){
            self.id = dmItem.id
            self.sectionType = .dm
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    struct MemberItem:Identifiable{
        var id:String{
            "\(memberID)"
        }
        var memberID:Int
    }
    struct DMItem:Identifiable{
        var id:String{
            "\(dmID)"
        }
        var dmID:Int
    }
}
