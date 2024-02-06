//
//  MessageContainerImage.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import Foundation
import SwiftUI
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
