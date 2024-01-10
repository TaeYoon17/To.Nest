//
//  AppendListItem.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import SwiftUI

struct AppendListBottom:View{
    let name:String
    var body:some View{
        Label(
            title: { Text(name) },
            icon: { Image(.plus).resizable().frame(width: 20,height: 20) }
        ).foregroundStyle(.secondary).font(FontType.body.font)
    }
}
