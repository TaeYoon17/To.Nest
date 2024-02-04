//
//  CHChat+CollectionStructure.swift
//  SolackProject
//
//  Created by 김태윤 on 1/28/24.
//

import Foundation
import UIKit
import SwiftUI
extension CHChatView{
    final class ChatItem:ObservableObject,Hashable,Identifiable{
        static func == (lhs: CHChatView.ChatItem, rhs: CHChatView.ChatItem) -> Bool {
            lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        var id : Int{ chatID }
        var chatID: Int = 0
        var content:String? = nil
        var images:[String] = []
        var createdAt:String
        var profileID:Int = 0
        var profileName:String = ""
        var profileImage:String? = nil
        init(chatResponse response: ChatResponse){
            self.chatID = response.chatID
            self.content = response.content
            self.images = response.files
            self.createdAt = response.createdAt.convertToDate().msgDateConverter()
            self.profileID = response.user.userID
            self.profileName = response.user.nickname
            self.profileImage = response.user.profileImage
        }
    }
    final class ChatAssets:ObservableObject,Identifiable{
        var id: Int{ chatID }
        var chatID:Int = 0
        var profileImages: Image?
        var images:[Image] = []
        init(chatID: Int, images: [Image]) {
            self.chatID = chatID
            self.images = images
        }
    }
}

