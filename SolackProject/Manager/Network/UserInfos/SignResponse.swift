//
//  SignUpResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
struct SignResponse: Codable {
    let userID: Int
    let email, nickname: String
    let profileImage: String? // URL로 바뀜!!
    let phone: String?
    let vendor: String?
    let createdAt: String
    let token: Token

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage, phone, vendor, createdAt, token
    }
}
struct Token: Codable {
    let accessToken, refreshToken: String
}
