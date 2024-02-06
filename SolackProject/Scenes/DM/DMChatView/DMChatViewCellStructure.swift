//
//  DMChatViewCellStructure.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit
import SwiftUI

extension DMChatView{

}
final class DMCellItem: MessageCellItem{
    var dmID:Int
    init(response: ChatResponse) {
        self.dmID = response.chatID
        super.init(id: response.chatID, images: response.files, createdAt: response.createdAt.convertToDate().convertToString(), profileID: response.user
            .userID, profileName: response.user.nickname)
    }
}
final class DMAsset: MessageAsset{
    var dmID:Int
    init(dmID: Int,images:[Image]) {
        self.dmID = dmID
        super.init(messageID: dmID, images: images)
    }
    required init(messageID: Int, images: [Image]) {
        self.dmID = messageID
        super.init(messageID: messageID, images: images)
    }
}
