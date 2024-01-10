//
//  DirectMsgListItemView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import SwiftUI
struct DirectMsgListItemView: View{
    var thumbnail:String
    var name:String
    var isUnreadExist:Bool
    var messageCount:Int
    var body: some View{
        if isUnreadExist{
            unread
        }else{
            allRead
        }
    }
    var unread: some View{
        Label(
            title: {
                HStack{
                    Text(name)
                    Spacer()
                    Text("\(messageCount)")
                        .foregroundStyle(.white)
                        .padding(.vertical,2)
                        .padding(.horizontal,4)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                }.font(FontType.bodyBold.font)
            },
            icon: {
                Image(thumbnail, bundle: nil).resizable().scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        )
    }
    var allRead: some View{
        Label(
            title: {
                HStack{
                    Text(name)
                    Spacer()
                    Text("\(messageCount)")
                        .font(FontType.bodyBold.font)
                        .foregroundStyle(.white)
                        .padding(.vertical,2)
                        .padding(.horizontal,4)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }.font(FontType.body.font)
            },
            icon: {
                Image(thumbnail).resizable().scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        ).foregroundStyle(.secondary)
    }
}
