//
//  WorkSpaceAlert.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import SwiftUI
extension View{
    func wsAlert(_ type:Binding<WSToastType?>) -> some View{
        self.modifier(WorkSpaceAlert(toastType: type))
    }
}
fileprivate struct WorkSpaceAlert:ViewModifier{
    @Binding var toastType : WSToastType?
    @State private var lackCoin = false
    @State private var notAuthority = false
    func body(content: Content) -> some View {
        content
            .solackAlert($lackCoin, title: "코인이 부족합니다", description: "", cancelTitle: "확인", cancel: {
                toastType = nil
            })
            .solackAlert($notAuthority, title: "권한이 없습니다", description: "관리자 계정이 아닙니다", cancelTitle: "확인", cancel: {
                toastType = nil
            })
            .onChange(of: toastType) { type in
                switch type{
                case .emptyData: break
                case .lackCoin: break
                case .notAuthority: notAuthority = true
                default:break
                }
            }
    }
}
