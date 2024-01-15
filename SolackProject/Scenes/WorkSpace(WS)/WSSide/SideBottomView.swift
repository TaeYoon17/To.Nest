//
//  SideBottomView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import SwiftUI
struct WorkSpaceBottomView:View{
    @EnvironmentObject fileprivate var vm:SideVM
    var body: some View{
        List{
            Button{
                vm.createWorkSpaceTapped.send(())
            }label:{
                Label(
                    title: { Text("워크스페이스 추가").font(FontType.body.font)},
                    icon: { Image(systemName: "plus") }
                )
                
            }.listRowSeparator(.hidden)
            Button{
                print("도움말말말")
            }label:{
                Label(
                    title: { Text("도움말")
                        .font(FontType.body.font)},
                    icon: { Image(systemName: "questionmark.circle") }
                ).listRowSeparator(.hidden)
            }
        }.tint(.secondary)
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollDisabled(true)
    }
}
