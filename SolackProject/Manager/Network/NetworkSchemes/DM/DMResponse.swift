//
//  DMResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 2/6/24.
//

import Foundation
struct DMResponse:Codable,Equatable,Sendable{
    static func == (lhs: DMResponse, rhs: DMResponse) -> Bool {
        lhs.dmID == rhs.dmID
    }
    var dmID:Int
    var roomID:Int?
    var content:String?
    var createdAt:String
    var files:[String]
    var user:UserResponse
    enum CodingKeys: String, CodingKey{
        case dmID = "dm_id"
        case roomID = "room_id"
        case content
        case createdAt
        case files
        case user
    }
}
