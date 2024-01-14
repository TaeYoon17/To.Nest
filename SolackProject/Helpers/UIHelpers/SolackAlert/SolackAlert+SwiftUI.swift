//
//  SolackAlert+SwiftUI.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import Foundation
import SwiftUI
struct SolackAlert: View{
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
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(FontType.body.font)
                            .multilineTextAlignment(.center)
                        if !infos.isEmpty{
                            Text(infos.reduce(into: "") { $0 = $0 + "• \($1)\n" })
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
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
        SolackSingleLabel(cancelAction: {
            withAnimation(.easeInOut(duration: 0.33)) { isVisible = false }
            Task{@MainActor in
                try await Task.sleep(for: .seconds(0.33))
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { fullScreenGo = false }
                cancel()
            }
        }, cancelTitle: cancelTitle)
    }
    var double:some View{
        SolackDoubleLabel(cancelTitle: cancelTitle, cancelAction: {
                            withAnimation(.easeInOut(duration: 0.33)) { isVisible = false }
                            Task{@MainActor in
                                try await Task.sleep(for: .seconds(0.33))
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) { fullScreenGo = false }
                                cancel()
                            }
        }, cinfirmAction: {
                            withAnimation(.easeInOut(duration: 0.33)) { isVisible = false }
                            Task{@MainActor in
                                try await Task.sleep(for: .seconds(0.33))
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) { fullScreenGo = false }
                                confirm?()
                            }
        }, confirmTitle: confirmTitle)
    }
}
