//
//  UserDialog.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
fileprivate struct UserDialog:ViewModifier{
    @Binding var isPresent:Bool
    let exit:()->()
    let cancel:()->()
    func body(content: Content) -> some View {
        content.confirmationDialog("userWorkSpace", isPresented: $isPresent) {
            Button("워크스페이스 편집"){
                exit()
            }
            Button("취소", role:.cancel){
                cancel()
            }
        }
    }
}
extension View{
    func userDialog(_ isPresent:Binding<Bool>,exit:@escaping ()->(),cancel:@escaping ()->()) ->some View{
        self.modifier(UserDialog(isPresent: isPresent, exit: exit, cancel: cancel))
    }
}
