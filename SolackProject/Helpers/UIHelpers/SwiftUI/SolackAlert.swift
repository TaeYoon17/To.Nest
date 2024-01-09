//
//  SolackAlert.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
// pg사 -> 카드사와 개발자를 연결해줌
// 자체 금융회사는 페이게이트를 쓰지 않는다. (수수료)
// pg사 서버 다운 문제 - 여러개를 붙인다.
fileprivate struct SolackAlert: View{
    @Binding var fullScreenGo:Bool
    @State private var isVisible = false
    let title: String
    let description:String
    let infos:[String]
    let cancelTitle:String
    let cancel:()->()
    let confirmTitle:String?
    let confirm:(()->())?
    var body: some View{
        ZStack {
            if isVisible{
                VStack(alignment:.center,spacing:16){
                    VStack(alignment: .center,spacing:8){
                        Text(title)
                            .font(FontType.title2.font)
                        Text(description)
                            .lineLimit(0)
                            .font(FontType.body.font)
                            .multilineTextAlignment(.center)
                        if !infos.isEmpty{
                            Text(infos.reduce(into: "") { $0 = $0 + "• \($1)\n" })
                        }
                    }.frame(maxWidth: .infinity)
                        
                    if let confirm{
                        double
                            
                    }else{
                        single
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical,16)
                .padding(.horizontal,16.5)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal,24)
                .onDisappear(){
                    fullScreenGo = false
                }
                .transition(.opacity)
                .zIndex(3)
            }
        }
        .onAppear{ 
            withAnimation(.easeInOut(duration: 0.33)) {
                isVisible = true
            }
        }
        .background(TransparentBackground(isVisible: $fullScreenGo))
        .opacity(isVisible ? 1 : 0)
        
        
    }
}
fileprivate extension SolackAlert{
    var single: some View{
        Button(action: {
            withAnimation(.easeInOut(duration: 0.33)) { isVisible = false }
            Task{@MainActor in
                try await Task.sleep(for: .seconds(0.33))
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { fullScreenGo = false }
                cancel()
            }
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
    var double:some View{
        HStack(alignment:.center,spacing:8){
            Button(action: {
                withAnimation(.easeInOut(duration: 0.33)) { isVisible = false }
                Task{@MainActor in
                    try await Task.sleep(for: .seconds(0.33))
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { fullScreenGo = false }
                    cancel()
                }
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
                withAnimation(.easeInOut(duration: 0.33)) { isVisible = false }
                Task{@MainActor in
                    try await Task.sleep(for: .seconds(0.33))
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { fullScreenGo = false }
                    confirm?()
                }
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
