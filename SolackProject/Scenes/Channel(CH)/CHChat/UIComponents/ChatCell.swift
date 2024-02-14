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
    let profileAction: ((Int)->Void)
    init(chatItem: CHChatView.ChatItem, images: CHChatView.ChatAssets, profileAction: @escaping (Int) -> Void) {
        self.chatItem = chatItem
        self.images = images
        self.profileAction = profileAction
    }
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
        Button(action: {
            self.profileAction(chatItem.profileID)
        }, label: {
            images.profileImages.resizable().scaledToFill()
                .background(.gray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width:34,height:34)
        })
    }
    var contents: some View{
        VStack(alignment:.leading,spacing:5){
            Text(chatItem.profileName).font(FontType.caption.font).foregroundStyle(.text)
            if let content = chatItem.content, !content.isEmpty{
                Text(content)
                    .font(FontType.body.font)
                    .padding(.all,8)
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
        Rectangle().fill(.clear).overlay(alignment: chatItem.profileID == userID ? .bottomTrailing:.bottomLeading) {
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
