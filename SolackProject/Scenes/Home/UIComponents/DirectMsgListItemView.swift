//
//  DirectMsgListItemView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import SwiftUI
struct DirectMsgListItemView: View{
    @ObservedObject var item:HomeVC.DirectListItem
//    var thumbnail:String
//    var name:String
//    var isUnreadExist:Bool
//    var messageCount:Int
    var body: some View{
        if item.messageCount > 0{
            unread
        }else{
            allRead
        }
    }
    var unread: some View{
        Label(
            title: {
                HStack{
                    Text(item.name)
                    Spacer()
                    Text("\(item.messageCount)")
                        .foregroundStyle(.white)
                        .padding(.vertical,2)
                        .padding(.horizontal,4)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                }.font(FontType.bodyBold.font)
            },
            icon: {
                item.thumbnail.resizable().scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        )
    }
    var allRead: some View{
        Label(
            title: {
                HStack{
                    Text(item.name)
                    Spacer()
                    if item.messageCount > 0{
                        Text("\(item.messageCount)")
                            .font(FontType.bodyBold.font)
                            .foregroundStyle(.white)
                            .padding(.vertical,2)
                            .padding(.horizontal,4)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }.font(FontType.body.font)
            },
            icon: {
                item.thumbnail.resizable().scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        ).foregroundStyle(.secondary)
    }
}
