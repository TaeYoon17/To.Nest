//
//  MessageCellItem.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import Foundation
import SwiftUI
class MessageCellItem:ObservableObject,Hashable,Identifiable{
    static func == (lhs: MessageCellItem, rhs: MessageCellItem) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    var id : Int{ messageID }
    @Published var messageID: Int = 0
    @Published var content:String? = nil
    @Published var images:[String] = []
    @Published var createdAt:String
    @Published var profileID:Int = 0
    @Published var profileName:String = ""
    @Published var profileImage:String? = nil
    init(id: Int, content: String? = nil, images: [String], createdAt: String, profileID: Int, profileName: String, profileImage: String? = nil) {
        self.messageID = id
        self.content = content
        self.images = images
        self.createdAt = createdAt
        self.profileID = profileID
        self.profileName = profileName
        self.profileImage = profileImage
    }
}
class MessageAsset:ObservableObject,Identifiable{
    var id: Int{ messageID }
    @Published var messageID:Int = 0
    @Published var profileImages: Image
    @Published var images:[Image] = []
    required init(messageID: Int, images: [Image],profileImage:Image?) {
        self.messageID = messageID
        self.images = images
        self.profileImages = profileImage ?? Image(.noPhotoA)
    }
}
