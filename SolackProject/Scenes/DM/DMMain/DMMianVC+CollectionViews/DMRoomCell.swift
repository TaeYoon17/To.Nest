//
//  RoomCell.swift
//  SolackProject
//
//  Created by 김태윤 on 2/8/24.
//

import Foundation
import SwiftUI

extension DMMainVC{
    struct DMRoomCell:View{
        @ObservedObject var item: DMRoomItem
        @ObservedObject var asset: DMAssets
        var body: some View{
            HStack(alignment:.top){
                asset.image.resizable().scaledToFill().frame(width: 34,height:34).clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(spacing:2) {
                    HStack{
                        Text(item.userName).font(FontType.caption.font)
                        Spacer()
                        Text(item.lastDate ?? "").font(FontType.caption2.font)
                    }
                    HStack(alignment:.top){
                        Text(item.lastContent ?? "").font(FontType.caption2.font)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Spacer()
                        if item.unreads > 0{
                            Text("\(item.unreads)")
                                .font(FontType.caption2.font)
                                .padding(.vertical,2).padding(.horizontal,4)
                                .background(.accent)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }.padding(.horizontal,8)
            }
        }
    }
}
