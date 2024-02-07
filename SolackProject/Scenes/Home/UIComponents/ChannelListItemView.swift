//
//  ChannelListItem.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import Foundation
import SwiftUI
struct ChannelListItemView: View{
    @ObservedObject var item: HomeVC.ChannelListItem
    var body: some View{
        if item.messageCount > 0{
            recent
        }else{
            notRecent
        }
    }
    var recent: some View{
        Label(
            title: {
                HStack{
                    Text(item.name)
                    Spacer()
                    if item.messageCount > 0{
                        Text("\(item.messageCount)")
                            .foregroundStyle(.white)
                            .padding(.vertical,2)
                            .padding(.horizontal,4)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }.font(FontType.bodyBold.font)
            },
            icon: {
                Image(.hashTagActive)
            }
        )
    }
    var notRecent: some View{
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
                Image(.hashTag)
            }
        ).foregroundStyle(.secondary)
    }
}
