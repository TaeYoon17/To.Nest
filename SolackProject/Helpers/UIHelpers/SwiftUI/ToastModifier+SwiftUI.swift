//
//  ToastModifier+SwiftUI.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import SwiftUI
import UIKit
import Toast
import Combine
struct Toastt:View{
    var type: (any ToastType)
    var body: some View{
        Text(type.contents)
            .font(FontType.body.font)
            .foregroundStyle(.white)
            .padding(.vertical,9)
            .padding(.horizontal,16)
            .background(Color(uiColor: type.getColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
struct ToastModifier:ViewModifier{
    @State private var undertype: (any ToastType)?
    @Binding var type: (any ToastType)?
    let alignment: Alignment
    func body(content: Content) -> some View {
        content.overlay(alignment:alignment) {
            if let undertype{
                Toastt(type: undertype )
                    .padding(.bottom)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }.onChange(of: type?.contents,perform:{ _ in
            guard let type else {return}
            Task{@MainActor in
                withAnimation { undertype = type }
                try await Task.sleep(for:.seconds(1.2))
                withAnimation {
                    undertype = nil
                    self.type = nil
                }
            }
        })
    }
}
//struct ToastModifier<P>:ViewModifier where P : Publisher, P.Failure == Never,P.Output == ToastType?{
//    @State var type: (any ToastType)? = nil
//    let publisher: P
//    let alignment: Alignment
//    func body(content: Content) -> some View {
//        content.overlay(alignment:alignment) {
//            if let type{
//                Toastt(type: type )
//                    .padding(.bottom)
//                    .transition(.opacity)
//                    .zIndex(10)
//            }
//        }.onReceive(publisher, perform: { value in
//            guard let value else {return}
//            Task{@MainActor in
//                withAnimation { self.type = value }
//                try await Task.sleep(for: .seconds(0.25))
//                withAnimation { self.type = nil }
//            }
//        })
//    }
//}
extension View{
//    func toast<P>(alignment:Alignment,publisher: P) -> some View where P : Publisher, P.Failure == Never,P.Output == ToastType?{
//        self.modifier(ToastModifier(publisher: publisher, alignment: alignment))
//    }
    func toast(type:Binding<ToastType?>,alignment:Alignment) -> some View{
        self.modifier(ToastModifier(type: type, alignment: alignment))
    }
}
