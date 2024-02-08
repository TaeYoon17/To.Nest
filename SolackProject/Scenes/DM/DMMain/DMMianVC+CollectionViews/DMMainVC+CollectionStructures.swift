//
//  DMMainVC+CollectionStructures.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import SwiftUI
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
        init(memberItem:DMMemberItem){
            self.id = memberItem.id
            self.sectionType = .member
        }
        init(roomItem:DMRoomItem){
            self.id = roomItem.id
            self.sectionType = .dm
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    final class DMMemberItem:MemberListItem{
        var sectionType:SectionType = .member
    }
    final class DMRoomItem:ObservableObject,Identifiable,Hashable{
        static func == (lhs: DMMainVC.DMRoomItem, rhs: DMMainVC.DMRoomItem) -> Bool {
            lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        var id:String{ "\(sectionType.rawValue)_\(roomID)" }
        private(set) var sectionType: SectionType = .dm
        var roomID:Int = 0
        @Published var userName:String
        @Published var userID:Int
        @Published var lastContent:String?
        @Published var profileImage:String?
        @Published var lastDate:String?
        init(roomID: Int, userName: String, lastContent: String? = nil, profileImage: String?, lastDate: String?,userID:Int) {
            self.roomID = roomID
            self.userName = userName
            self.lastContent = lastContent
            self.profileImage = profileImage
            self.lastDate = lastDate
            self.userID = userID
        }
        convenience init(roomResponse info:DMRoomResponse){
            self.init(roomID: info.roomID, userName: info.user.nickname, lastContent: info.content, profileImage: info.user.profileImage, lastDate: info.lastDate?.msgDateConverter(), userID: info.user.userID)
        }
    }
    final class DMAssets: MemberListAsset{
        
    }
}
