//
//  ManagerDialog.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
fileprivate struct ManagerDialog:ViewModifier{
    @Binding var isPresent:Bool
    let edit:()->()
    let delete:()->()
    let change:()->()
    let exit:()->()
    let cancel:()->()
    func body(content: Content) -> some View {
        content.confirmationDialog("managerWorkSpace", isPresented: $isPresent) {
            Button("워크스페이스 편집"){
                edit()
            }
            Button("워크스페이스 나가기"){
                exit()
            }
            Button("워크스페이스 관리자 변경"){
                change()
            }
            Button("워크스페이스 삭제", role:.destructive){
                delete()
            }
            Button("취소", role:.cancel){
                cancel()
            }
        }
    }
}

extension View{
    func managerDialog(_ isPresent:Binding<Bool>,
                       edit:@escaping ()->(),
                       delete:@escaping ()->(),
                       change:@escaping ()->(),
                       exit:@escaping ()->(),
                       cancel:@escaping ()->()) -> some View{
        self.modifier(ManagerDialog(isPresent: isPresent, edit: edit, delete: delete, change: change, exit: exit, cancel: cancel))
    }
}
