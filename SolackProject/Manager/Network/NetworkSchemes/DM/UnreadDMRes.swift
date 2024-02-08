//
//  UnreadDMRes.swift
//  SolackProject
//
//  Created by 김태윤 on 2/8/24.
//

import Foundation
struct UnreadDMRes:Codable{
    var roomID:Int
    var count:Int
    enum CodingKeys: String, CodingKey{
        case roomID = "room_id"
        case count
    }
}
