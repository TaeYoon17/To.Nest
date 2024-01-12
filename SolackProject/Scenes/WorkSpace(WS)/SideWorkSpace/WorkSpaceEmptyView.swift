//
//  WorkSpaceEmptyView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
struct WorkSpaceEmpty:View {
    let createAction:()->Void
    var body: some View {
        VStack(alignment:.center,spacing:18){
            Text("워크스페이스를\n찾을 수 없어요.").font(FontType.title1.font)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineSpacing(4)
            Text("관리자에게 초대를 요청하거나,\n다른 이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요").font(FontType.body.font)
                .lineLimit(3)
                .multilineTextAlignment(.center)
            Button(action: {
                createAction()
            } , label: {
                Text("워크스페이스 생성")
                    .font(FontType.title2.font)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(.accent).foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal,24)
            })
        }
    }
}
