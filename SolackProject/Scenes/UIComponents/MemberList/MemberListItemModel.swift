//
//  MemberListItem.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import SwiftUI
class MemberListItem:ObservableObject,Identifiable{
   static func == (lhs: MemberListItem, rhs: MemberListItem) -> Bool {
       lhs.id == rhs.id
   }
   func hash(into hasher: inout Hasher) {
       hasher.combine(id)
   }
   var id: String{"\(userResponse.userID)" } // 유저 고유 번호를 ID로 채택할 필요 있음
   @Published var userResponse:UserResponse
   init(userResponse: UserResponse) {
       self.userResponse = userResponse
   }
}
class MemberListAsset:Identifiable,ObservableObject{
    static func == (lhs: MemberListAsset, rhs: MemberListAsset) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var id: String
    @Published var image:Image
    init(userId: String,image:UIImage){
        self.id = userId
        self.image = Image(uiImage: image)
    }
}
