//
//  DMChatsResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 2/7/24.
//

import Foundation
struct DMChatsResponse:Codable{
    var workspaceID:Int
    var roomID:Int
    var chats:[DMResponse]
    enum CodingKeys: String, CodingKey{
        case workspaceID = "workspace_id"
        case roomID = "room_id"
        case chats
    }
}
