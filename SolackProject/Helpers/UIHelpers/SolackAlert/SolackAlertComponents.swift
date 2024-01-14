//
//  SolackAlertComponents.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import Foundation
import SwiftUI
fileprivate struct SolackAlertModifier:ViewModifier{
    @Binding var isPresent:Bool
    let title: String
    let description:String
    let infos:[String]
    let cancelTitle:String
    let cancel:()->()
    let confirmTitle:String?
    let confirm:(()->())?
    func body(content: Content) -> some View {
        content.fullScreenCover(isPresented: $isPresent, content: {
            SolackAlert(fullScreenGo: $isPresent, title: title, description: description, infos: infos, cancelTitle: cancelTitle, cancel: cancel, confirmTitle: confirmTitle, confirm: confirm)
        })
    }
}
extension View{
    func solackAlert(_ isPresent:Binding<Bool>,
                     title:String,
                     description:String,
                     infos:[String] = [],
                     cancelTitle:String,
                     cancel:@escaping ()->(),
                     confirmTitle:String? = nil,
                     confirm:(()->())? = nil) -> some View{
        self.modifier(SolackAlertModifier(isPresent: isPresent, title: title, description: description, infos: infos, cancelTitle: cancelTitle, cancel: cancel, confirmTitle: confirmTitle, confirm: confirm))
    }
}
struct SolackSingleLabel: View{
    let cancelAction:()->()
    let cancelTitle:String
    var body: some View{
        Button(action: {
            cancelAction()
        }, label: {
            Text(cancelTitle)
                .font(FontType.title2.font)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        })
    }
}
struct SolackDoubleLabel:View{
    let cancelTitle:String
    let cancelAction:()->()
    let cinfirmAction: (()->())?
    let confirmTitle: String?
    var body: some View{
        HStack(alignment:.center,spacing:8){
            Button(action: {
                cancelAction()
            }, label: {
                Text(cancelTitle)
                    .font(FontType.title2.font)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(.gray5)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            })
            Button(action: {
                cinfirmAction?()
            }, label: {
                Text(confirmTitle ?? "")
                    .font(FontType.title2.font)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            })
        }.frame(height: 44)
        .frame(maxWidth: .infinity)
    }
}
