//
//  ChangeManagerListCell.swift
//  SolackProject
//
//  Created by 김태윤 on 2/2/24.
//

import SwiftUI

struct ChangeManagerListCell: View{
    var body: some View{
        HStack(spacing:8){
            Image(.arKit).resizable().scaledToFit().frame(width: 44,height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment:.leading,spacing:0){
                Text("Coutrney Henry")
                    .font(FontType.bodyBold.font)
                    .foregroundStyle(.text)
                    .frame(height: 18)
                
                Text(verbatim:"michelle.rivera@example.com")
                    .font(FontType.body.font)
                    .foregroundStyle(.secondary)
                    .frame(height:18)
            }
            Spacer()
        }
    }
}
