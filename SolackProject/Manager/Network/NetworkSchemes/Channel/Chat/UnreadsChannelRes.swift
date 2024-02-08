//
//  UnreadsChannelRes.swift
//  SolackProject
//
//  Created by 김태윤 on 2/8/24.
//

import Foundation
struct UnreadsChannelRes:Codable{
    var channelID: Int
    var name: String
    var count:Int
    enum CodingKeys: String, CodingKey{
        case channelID = "channel_id"
        case name
        case count
    }
}
