//
//  HomeVC+CollectionStructures.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import Foundation
import SwiftUI
extension HomeVC{
    enum SectionType:String{
        case channel
        case direct
        case team
    }
    enum ItemType:String{
        case header
        case list
        case bottom
    }
    struct Item:Identifiable,Hashable{
        var id:String // 문자열로 고유값 적용... uuidString 및 identifier uuidString이 달라야한다.
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
    final class ChannelListItem:ObservableObject,Identifiable,CollectionItemable{
        static func == (lhs: HomeVC.ChannelListItem, rhs: HomeVC.ChannelListItem) -> Bool {
            lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        let itemType: ItemType = .list
        let sectionType: SectionType = .channel
        var id:String{"\(channelID)"}
        var channelID:Int = 0
        @Published var name :String
        @Published var messageCount:Int
        @Published var isRecent: Bool
        init(channelID: Int, name: String, messageCount: Int, isRecent: Bool) {
            self.channelID = channelID
            self.name = name
            self.messageCount = messageCount
            self.isRecent = isRecent
        }
    }
    struct DirectListItem: Identifiable,CollectionItemable{
        let itemType:ItemType = .list
        let sectionType: HomeVC.SectionType = .direct
        var id:String{ name }
        var name:String
        var imageData: String // 임시로 이름 넣기
        var messageCount:Int
        var unreadExist: Bool
    }
    struct BottomItem:Identifiable,Hashable,CollectionItemable{
        var id :String{ sectionType.rawValue+itemType.rawValue }
        let itemType: HomeVC.ItemType = .bottom // 혹시 모를 해싱 고유값 중첩 문제
        var sectionType: HomeVC.SectionType
        var name:String
    }
    struct HeaderItem:Identifiable,Hashable,CollectionItemable{
        var id:String{ sectionType.rawValue + itemType.rawValue}
        var itemType: HomeVC.ItemType = .header
        var sectionType: HomeVC.SectionType
        var name:String
    }
}
