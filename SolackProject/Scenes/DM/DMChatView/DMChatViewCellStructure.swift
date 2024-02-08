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
    init(response info:DMResponse) {
        self.dmID = info.dmID
        super.init(id: info.dmID, content: info.content, images: info.files, createdAt: info.createdAt.convertToDate().msgDateConverter(), profileID: info.user.userID, profileName: info.user.nickname, profileImage: info.user.profileImage)
    }
    
}
final class DMAsset: MessageAsset{
    var dmID:Int
    init(dmID: Int,images:[Image],profileImage:Image?) {
        self.dmID = dmID
        super.init(messageID: dmID, images: images,profileImage: profileImage)
    }
    required init(messageID: Int, images: [Image],profileImage:Image?) {
        self.dmID = messageID
        super.init(messageID: messageID, images: images,profileImage: profileImage)
    }
}
