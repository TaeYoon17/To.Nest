//
//  MemberListItem.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import SwiftUI
struct MemberButton: View{
    @ObservedObject var item: MemberListItem
    @ObservedObject var asset: MemberListAsset
    let action:(UserResponse)->()

    var body: some View{
        Button{
            action(item.userResponse)
        }label:{
            VStack(alignment:.center){
                asset.image.resizable().scaledToFit().frame(width: 44,height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(
                    item.userResponse.nickname.isEmpty ? "이름 없는 사용자" : item.userResponse.nickname
                ).font(FontType.body.font)
            }
        }.tint(.text)
    }
}
