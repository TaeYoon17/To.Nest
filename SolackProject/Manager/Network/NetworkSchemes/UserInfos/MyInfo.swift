//
//  MyInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/31/24.
//

import Foundation
struct MyInfo:Codable{
    var userID: Int
    var email, nickname: String
    var profileImage: String? // URL로 바뀜!!
    var phone: String?
    var vendor: String?
    var createdAt: String
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage, phone, vendor, createdAt
    }
}
