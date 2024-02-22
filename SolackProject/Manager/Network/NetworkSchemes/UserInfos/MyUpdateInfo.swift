//
//  MyInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/31/24.
//

import Foundation
struct MyUpdateInfo:Codable{
    var userID: Int
    var email, nickname: String
    var sesacCoin:Int?
    var profileImage: String? // URL로 바뀜!!
    var phone: String?
    var vendor: String?
    var createdAt: String
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage, phone, vendor, createdAt
    }
}
struct MyInfo:Codable{
    var userID: Int
    var sesacCoin:Int
    var email, nickname: String
    var profileImage: String? // URL로 바뀜!!
    var phone: String?
    var vendor: String?
    var createdAt: String
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage, phone, vendor, createdAt
        case sesacCoin
    }
    mutating func updateInfo(_ updateInfo: MyUpdateInfo){
        self.userID = updateInfo.userID
        self.email = updateInfo.email
        self.nickname = updateInfo.nickname
        self.profileImage = updateInfo.profileImage
        self.phone = updateInfo.phone
        self.vendor = updateInfo.vendor
        self.createdAt = updateInfo.createdAt
    }
}
