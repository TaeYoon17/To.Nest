//
//  ChatResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
struct ChatResponse:Codable{
    var channelID:Int
    var channelName:String
    var chatID: Int
    var content:String?
    var createdAt:String
    var files:[String]
    var user:[UserResponse]
    enum CodingKeys: String, CodingKey{
        case channelID = "channel_id"
        case channelName
        case chatID = "chat_id"
        case content
        case createdAt
        case files
        case user
    }
}
