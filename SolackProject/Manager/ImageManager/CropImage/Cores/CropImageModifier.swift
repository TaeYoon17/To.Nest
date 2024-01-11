//
//  ImageModifier.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import SwiftUI
fileprivate struct AnimationToggler:ViewModifier{
    @State var toggler: Bool = false
    func body(content: Content) -> some View {
        content
            .opacity(toggler ? 1 : 0)
            .transition(.opacity)
            .onAppear(){
                toggler = false
                withAnimation(.easeInOut(duration: 0.2)) { toggler = true }
            }
            .onDisappear(){
                toggler = false
        }
    }
}
    
extension View{
    func animToggler()->some View{
        self.modifier(AnimationToggler())
    }
}
extension View{
    func frame(_ size:CGSize) -> some View{
        self.frame(width: size.width,height: size.height)
    }
}
