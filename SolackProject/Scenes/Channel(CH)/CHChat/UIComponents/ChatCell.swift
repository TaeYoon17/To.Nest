//
//  ChatCell.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import Foundation
import SwiftUI
struct ChatUser{
    let nickName: String
    let thumbnail:String
}
struct ChatCell:View{
    let message:String
    let date:String = "08:16 오전"
    let chatUser = ChatUser(nickName: "옹골찬 고래밥", thumbnail: "heart")
    //    var images:[String] = ["ARKit","macOS" ]
    @State private var dateWidth:CGFloat = 0
    @State var realImage:[Image] = []
    @State private var show = false
    var body: some View{
        HStack(alignment:.top){
            Image(.asyncSwift).resizable().scaledToFill()
                .background(.gray6)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width:34,height:34)
            VStack(alignment:.leading,spacing:5){
                Text(chatUser.nickName).font(FontType.caption.font)
                Text(message)
                    .font(FontType.body.font)
                    .padding(.all,8)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 12).strokeBorder()
                    })
                if realImage.count > 0{
                    ContainerImage(realImage: $realImage)
                        .drawingGroup()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Rectangle().fill(.clear).overlay(alignment:.bottomLeading) {
                Text(date)
                    .foregroundStyle(.secondary)
                    .font(FontType.caption.font)
                    .onAppear(){
                        let label = UILabel()
                        label.font = FontType.caption.get()
                        label.text = date
                        self.dateWidth = label.intrinsicContentSize.width + 8
                    }
            }.frame(width: dateWidth)
        }
        .transaction{ transaction in
            transaction.animation = nil
        }
    }
}
struct ContainerImage:View{
    //    let images:[String]
    @Binding var realImage:[Image]
    var body: some View{
        switch realImage.count{
        case 0: EmptyView().frame(height:0)
        case 1: realImage[0].resizable().scaledToFill().clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width:240,height:160)
        case 2:
            HStack(spacing: 4, content: {
                realImage[0].resizable().scaledToFill().clipped()
                realImage[1].resizable().scaledToFill().clipped()
            })
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 240,height: 80)
        case 3:
            HStack(spacing: 2, content: {
                realImage[0].resizable().scaledToFit().clipped()
                realImage[1].resizable().scaledToFit().clipped()
                realImage[2].resizable().scaledToFit().clipped()
            }).frame(width: 240,height: 80)
        case 4:
            VStack(alignment:.center,spacing: 2, content: {
                HStack(spacing:2,content: {
                    realImage[0].resizable().scaledToFill().clipped()
                    realImage[1].resizable().scaledToFill().clipped()
                }).frame(width: 240,height: 80)
                    .clipped()
                HStack(alignment:.center,spacing:2,content: {
                    realImage[2].resizable().scaledToFill().clipped()
                    realImage[3].resizable().scaledToFill().clipped()
                }).frame(width: 240,height: 80)
                    .clipped()
            })
            .frame(width: 240, height:160)
        default:
            VStack(alignment:.center , spacing:2,content: {
                HStack(spacing:2,content: {
                    realImage[0].resizable().scaledToFill().clipped()
                    realImage[1].resizable().scaledToFill().clipped()
                    realImage[2].resizable().scaledToFill().clipped()
                }).frame(width: 240,height: 80)
                    .clipped()
                HStack(alignment:.center, spacing:2,content: {
                    realImage[3].resizable().scaledToFill().clipped()
                    realImage[4].resizable().scaledToFill().clipped()
                }).frame(width: 240,height: 80)
                    .clipped()
            })
            .frame(width: 240, height:160)
            .background(.pink)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        
        
    }
}
#Preview {
    List{
        ChatCell(message: "Hello world!!")
    }.listStyle(.plain)
}
