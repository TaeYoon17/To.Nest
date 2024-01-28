//
//  CHChat+CollectionStructure.swift
//  SolackProject
//
//  Created by 김태윤 on 1/28/24.
//

import Foundation
import UIKit
extension CHChatView{
    struct ChatItem:Hashable,Identifiable{
        var id : Int{ chatID }
        let chatID: Int
        let content:String?
        let images:[String]
        let createdAt:Date
    }
}
