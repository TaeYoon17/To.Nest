//
//  WSResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
struct WSResponse:Codable{
    var workspaceID:Int
    var name:String
    var description:String?
    var thumbnail:String //url
    var ownerID: Int
    var createdAt: String
    enum CodingKeys: String, CodingKey{
        case workspaceID = "workspace_id"
        case name
        case description
        case thumbnail
        case ownerID = "owner_id"
        case createdAt
    }
}
