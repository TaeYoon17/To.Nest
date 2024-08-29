//
//  MessageCell.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import SwiftUI
struct MessageCell:View{
    @ObservedObject var msgItem: MessageCellItem
    @ObservedObject var images: MessageAsset
    @DefaultsState(\.userID) var userID
    @State private var date:String = "08:16 오전"
    @State private var dateWidth:CGFloat = 0
    @State private var show = false
    let profileAction: ((Int)->Void)
    init(msgItem: MessageCellItem, images: MessageAsset,  profileAction: @escaping (Int) -> Void) {
        self.msgItem = msgItem
        self.images = images
        self.profileAction = profileAction
    }
    var body: some View{
        if userID == msgItem.profileID{
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
            Spacer()
        }.transaction{ transaction in
            transaction.animation = nil
        }
    }
    var myUser: some View{
        HStack(alignment:.top){
            Spacer()
            dates
            VStack(alignment:.trailing,spacing:5){
                if let content = msgItem.content, !content.isEmpty{
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
extension MessageCell{
    var profile:some View{
        Button(action: {
            self.profileAction(msgItem.profileID)
        }, label: {
            images.profileImages.resizable().scaledToFill()
                .background(.gray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width:34,height:34)
        })
    }
    var contents: some View{
        VStack(alignment:.leading,spacing:5){
            Text(msgItem.profileName).font(FontType.caption.font)
            if let content = msgItem.content, !content.isEmpty{
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
        Rectangle().fill(.clear).overlay(alignment: msgItem.profileID == userID ? .bottomTrailing : .bottomLeading) {
            Text(msgItem.createdAt)
                .foregroundStyle(.secondary)
                .font(FontType.caption.font)
                .multilineTextAlignment(msgItem.profileID == userID ? .trailing : .leading)
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
