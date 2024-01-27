//
//  UserInfoTable.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import RealmSwift
// 캐싱 프로파일 업데이트가 필요할 수 있다.
// (다른 사람이 계정이름을 바꾸거나 프로필 이미지를 바꿀 수 있다.)
// 그냥 유저 아이디만 받아서 메모리 캐시를 사용하는게 더 나을 수도..?
final class UserInfoTable:Object,Identifiable{
    @Persisted(primaryKey: true) var userID: Int
    @Persisted(originProperty: "userInfo") var parentSet: LinkingObjects<CHChatTable>
    @Persisted var email: String
    @Persisted var nickName:String
    @Persisted var profileImage:String
    convenience init(email:String,nickName:String,profileImage:String) {
        self.init()
        self.email = email
        self.nickName = nickName
        self.profileImage = profileImage
    }
}
