//
//  UserResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
struct UserResponse:Codable{
    var userID: Int
    var email: String
    var nickname: String
    var profileImage: String?
    enum CodingKeys: String, CodingKey{
        case userID = "user_id"
        case email
        case nickname
        case profileImage
    }
}
extension UserResponse: Equatable,Hashable{
    mutating func convertWebPathToFilePath(){
        self.profileImage = self.profileImage?.webFileToDocFile()
    }
}
    
