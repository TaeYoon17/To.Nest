//
//  CHResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
struct CHResponse:Codable{
    var workspaceID:Int
    var channelID: Int
    var name:String
    var description:String? // 채널에 대한 설명
    var ownerID: Int
    var privateNumber:Int // 채널 비공개 여부: 0일 경우 공개, 1일 경우 비공개
    var createdAt: String
    enum CodingKeys: String, CodingKey{
        case workspaceID = "workspace_id"
        case channelID = "channel_id"
        case name
        case description
        case ownerID = "owner_id"
        case privateNumber = "private"
        case createdAt
    }
}
