//
//  WSResDetail.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
struct WSDetailResponse:Codable{
    var workspaceID:Int
    var name:String
    var description:String?
    var thumbnail:String //url
    var ownerID: Int
    var createdAt: String
    var channels:[CHResponse]?
    var workspaceMembers:[UserResponse]?
    enum CodingKeys: String, CodingKey{
        case workspaceID = "workspace_id"
        case name
        case description
        case thumbnail
        case ownerID = "owner_id"
        case createdAt
        case channels
        case workspaceMembers
    }
}

