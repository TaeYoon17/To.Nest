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
    final class ChatItem: MessageCellItem{
        var chatID: Int = 0
        init(chatResponse response: ChatResponse) {
            self.chatID = response.chatID
            super.init(id: response.chatID,
                       content: response.content,
                       images: response.files,
                       createdAt: response.createdAt.convertToDate().msgDateConverter(),
                       profileID: response.user.userID,
                       profileName: response.user.nickname,
                       profileImage: response.user.profileImage
            )
        }
    }
    final class ChatAssets: MessageAsset{
        var chatID:Int = 0
        init(chatID: Int, images: [Image]) {
            self.chatID = chatID
            super.init(messageID: chatID, images: images)
        }
        required init(messageID: Int, images: [Image]) {
            super.init(messageID: messageID, images: images)
        }
    }
}

