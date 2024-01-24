//
//  CHSettingCollectionStructures.swift
//  SolackProject
//
//  Created by 김태윤 on 1/24/24.
//

import Foundation
extension CHSettingView{
    enum SectionType:String{
        case info
        case member
        case editing
    }
    enum ItemType:String{
        case header
        case listItem
        case bottom
    }
    struct Item:Identifiable,Hashable{
        var id:String
        var sectionType:SectionType
        var itemType: ItemType
        
        init<T:CollectionItemable>(_ itemAble:T)where T.ItemType == ItemType, T.SectionType == SectionType{
            self.id = itemAble.id
            self.itemType = itemAble.itemType
            self.sectionType = itemAble.sectionType
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    struct InfoItem:CollectionItemable{
        var id: String{sectionType.rawValue + itemType.rawValue }
        var sectionType:SectionType = .info
        var itemType: ItemType = .listItem
        var description:String = "안녕하세요 새싹 여러분? 심심하셨죠? 이 채널은 나머지 모든 것을 위한 채널이에요. 팀원들이 농담하거나 순간적인 아이디어를 공유하는 곳이죠! 마음껏 즐기세요!"
    }
    struct MemberListItem:CollectionItemable,Identifiable{
        var id: String{UUID().uuidString } // 유저 고유 번호를 ID로 채택할 필요 있음
        var sectionType:SectionType = .member
        var itemType: ItemType = .listItem
        var name:String
        // 유저 썸네일을 받아올 필요 있음
    }
    struct MemberListHeader: CollectionItemable{
        var id:String{sectionType.rawValue + itemType.rawValue }
        var sectionType: SectionType = .member
        var itemType: ItemType = .header
        var numbers:Int
    }
    struct EditListItem: CollectionItemable,Identifiable{
        var id:String{ editingType.rawValue }
        var sectionType: SectionType = .editing
        var itemType: ItemType = .listItem
        var editingType:CHEditingType
    }
}

