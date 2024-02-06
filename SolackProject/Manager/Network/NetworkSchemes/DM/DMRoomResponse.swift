//
//  DMResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation

struct DMRoomResponse:Codable{
    var workspaceID:Int
    var roomID:Int
    var createdAt:String
    var user:UserResponse
    enum CodingKeys: String, CodingKey{
        case workspaceID = "workspace_id"
        case roomID = "room_id"
        case createdAt
        case user
    }
}
