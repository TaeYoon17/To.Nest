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
        static func getByNumber(_ value:Int) -> Self?{
            switch value{
            case 0:return .info
            case 1:return .member
            case 2:return .editing
            default: return nil
            }
        }
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
        var title:String = ""
        var description:String = ""
    }
    struct MemberListItem:CollectionItemable,Identifiable{
        var id: String{"\(userResponse.userID)" } // 유저 고유 번호를 ID로 채택할 필요 있음
        var sectionType:SectionType = .member
        var itemType: ItemType = .listItem
        var userResponse:UserResponse
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
