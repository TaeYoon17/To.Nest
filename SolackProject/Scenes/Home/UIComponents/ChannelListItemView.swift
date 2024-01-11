//
//  ChannelListItem.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import Foundation
import SwiftUI
struct ChannelListItemView: View{
    var isRecent:Bool
    let name:String
    let count:Int
    var body: some View{
        if isRecent{
            recent
        }else{
            notRecent
        }
    }
    var recent: some View{
        Label(
            title: {
                HStack{
                    Text(name)
                    Spacer()
                    Text("\(count)")
                        .foregroundStyle(.white)
                        .padding(.vertical,2)
                        .padding(.horizontal,4)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
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
                    Text(name)
                    Spacer()
                    Text("\(count)")
                        .font(FontType.bodyBold.font)
                        .foregroundStyle(.white)
                        .padding(.vertical,2)
                        .padding(.horizontal,4)
                        .background(.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }.font(FontType.body.font)
            },
            icon: {
                Image(.hashTag)
            }
        ).foregroundStyle(.secondary)
    }
}
