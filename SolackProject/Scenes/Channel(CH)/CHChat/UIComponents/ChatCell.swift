//
//  ChatCell.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import Foundation
import SwiftUI

struct ChatCell:View{
    @ObservedObject var chatItem: CHChatView.ChatItem
    @ObservedObject var images: CHChatView.ChatAssets
    @DefaultsState(\.userID) var userID
    @State private var date:String = "08:16 오전"
    @State private var dateWidth:CGFloat = 0
    @State private var show = false
    var body: some View{
        if userID == chatItem.profileID{
            myUser
        }else{
            otherUser
        }
    }
    var otherUser: some View{
        HStack(alignment:.top){
            profile
            contents
            dates
        }.transaction{ transaction in
            transaction.animation = nil
        }
    }
    var myUser: some View{
        HStack(alignment:.top){
            Spacer()
            dates
            VStack(alignment:.trailing,spacing:5){
                if let content = chatItem.content, !content.isEmpty{
                    Text(content)
                        .font(FontType.body.font)
                        .padding(.all,8)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 12).strokeBorder()
                    })
                }
                if !images.images.isEmpty{
                    ContainerImage(realImage: $images.images)
                        .drawingGroup()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }.transaction{ transaction in
            transaction.animation = nil
        }
    }
}
extension ChatCell{
    var profile:some View{
        Image(.asyncSwift).resizable().scaledToFill()
            .background(.gray6)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width:34,height:34)
    }
    var contents: some View{
        VStack(alignment:.leading,spacing:5){
            Text(chatItem.profileName).font(FontType.caption.font)
            if let content = chatItem.content, !content.isEmpty{
                Text(content)
                    .font(FontType.body.font)
                    .padding(.all,12)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 12).strokeBorder()
                })
            }
            if !images.images.isEmpty{
                ContainerImage(realImage: $images.images)
                    .drawingGroup()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    var dates: some View{
        Rectangle().fill(.clear).overlay(alignment:.bottomTrailing) {
            Text(chatItem.createdAt)
                .foregroundStyle(.secondary)
                .font(FontType.caption.font)
                .multilineTextAlignment(chatItem.profileID == userID ? .trailing : .leading)
                .onAppear(){
                    let label = UILabel()
                    label.font = FontType.caption.get()
                    label.text = "1/28 03:50"
                    self.dateWidth = label.intrinsicContentSize.width + 4
                }
        }
        .frame(width: dateWidth)
    }
}
struct ContainerImage:View{
    @Binding var realImage:[Image]
    let width:CGFloat = 220
    var body: some View{
        switch realImage.count{
        case 0: EmptyView().frame(height:0)
        case 1: realImage[0].resizable().scaledToFill().clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(height: 160)
        case 2:
            HStack(spacing: 4, content: {
                realImage[0].resizable().scaledToFill().clipped()
                realImage[1].resizable().scaledToFill().clipped()
            })
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(height: 80)
        case 3:
            HStack(spacing: 2, content: {
                realImage[0].resizable().scaledToFill().clipped()
                realImage[1].resizable().scaledToFill().clipped()
                realImage[2].resizable().scaledToFill().clipped()
            }).clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(height: 80)
        case 4:
            VStack(alignment:.center,spacing: 2, content: {
                HStack(spacing:2,content: {
                    realImage[0].resizable().scaledToFill().clipped()
                    realImage[1].resizable().scaledToFill().clipped()
                })
                .frame(height:80)
                    .clipped()
                HStack(alignment:.center,spacing:2,content: {
                    realImage[2].resizable().scaledToFill().clipped()
                    realImage[3].resizable().scaledToFill().clipped()
                })
                .frame(height: 80)
                    .clipped()
            })
//            .frame(width: width, height:160)
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        default:
            VStack(alignment:.center , spacing:2,content: {
                HStack(spacing:2,content: {
                    realImage[0].resizable().scaledToFill().clipped()
                    realImage[1].resizable().scaledToFill().clipped()
                    realImage[2].resizable().scaledToFill().clipped()
                })
                .frame(height: 80)
                    .clipped()
                HStack(alignment:.center, spacing:2,content: {
                    realImage[3].resizable().scaledToFill().clipped()
                    realImage[4].resizable().scaledToFill().clipped()
                })
                .frame(height: 80)
                    .clipped()
            })
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        
        
    }
}
//#Preview {
//    List{
//        ChatCell(message: "Hello world!!", chatUser: .init(nickName: "고래고래박", thumbnail: "Metal"))
//    }.listStyle(.plain)
//}

