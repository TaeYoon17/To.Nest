//
//  InfoUpdateView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/30/24.
//

import SwiftUI
extension InfoUpdateView{
    struct StaticView{
        let title: String
        let placeholder: String
    }
    enum UpdateType{
        case nickname
        case phone
        var staticView:StaticView{
            switch self{
            case .nickname:
                StaticView(title: "닉네임", placeholder: "닉네임을 입력하세요")
            case .phone:
                StaticView(title: "연락처", placeholder: "전화번호를 입력하세요")
            }
        }
    }
}
struct InfoUpdateView: View{
    @EnvironmentObject var vm: MyProfileReactor
    @Environment(\.dismiss) var dismiss
    let placeholder: String
    let title:String
    let myType: UpdateType
    @State var text = ""
    @FocusState private var isFocused: Bool
    @State private var isComfirmable = false
    @State private var toastType: ToastType? = nil
    init(type:UpdateType){
        self.myType = type
        self.placeholder = type.staticView.placeholder
        self.title = type.staticView.title
    }
    var body: some View{
        contents
            .toast(type: $toastType, alignment: .bottom, position: .zero)
            .contentModi()
            .onTapGesture {
                if isFocused{ isFocused = false }
            }
        .defaultNaviBack(title: title, action: { dismiss() })
        // MARK: -- Action 영역
        .onChange(of: text, perform: { newValue in
            switch myType {
            case .nickname: self.vm.action.onNext(.setNicName(newValue))
            case .phone: self.vm.action.onNext(.setPhone(newValue))
            }
        })
        // MARK: -- Receive 영역
        .onReceive(vm.$st, perform: { perform in
            switch myType {
            case .nickname:
                self.isComfirmable =  perform.isNickNameConvertable
                self.text = perform.nickname
            case .phone:
                self.isComfirmable = perform.isPhoneConvertable
                self.text = perform.phone
            }
            self.toastType = perform.toast
        })
        .onChange(of: vm.st.isCompletedChanged) { newValue in
            if newValue == true{
                dismiss()
            }
        }
    }
}
#Preview {
    InfoUpdateView(type: .nickname)
}
extension InfoUpdateView{
    var contents: some View{
        ZStack(alignment: .bottom){
            Color.gray2
            List{
                TextField(text: $text) { Text(placeholder).font(FontType.body.font) }.font(FontType.body.font)
                    .keyboard(type:myType)
                    .focused($isFocused)
            }
            Button(action: {
                switch myType {
                case .nickname: vm.action.onNext(.applyNicknameUpdate)
                case .phone: vm.action.onNext(.applyPhoneUpdate)
                }
            }, label: {
                HStack{
                    Spacer()
                    Text("완료")
                    Spacer()
                }
                .font(FontType.title2.font)
                .foregroundStyle(.white)
                .frame(height: 44)
                .background(isComfirmable ? .accent : .gray3)
                
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal,24)
            })
            .allowsHitTesting(isComfirmable)
            .padding(.bottom,isFocused ? 12 : 0)
            
        }
    }
}
extension InfoUpdateView{
    fileprivate struct KeyBoardTypeModifier: ViewModifier{
        var infoType:UpdateType
        func body(content: Content) -> some View {
            switch infoType {
            case .nickname:
                content.keyboardType(.default)
            case .phone:
                content.keyboardType(.numberPad)
            }
        }
    }
    fileprivate struct ContentModifier: ViewModifier{
        func body(content: Content) -> some View {
            content.background(.gray2)
                .scrollContentBackground(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
        }
    }
}
fileprivate extension View{
    func keyboard(type: InfoUpdateView.UpdateType) -> some View{
        self.modifier(InfoUpdateView.KeyBoardTypeModifier(infoType: type))
    }
    func contentModi() -> some View{
        self.modifier(InfoUpdateView.ContentModifier())
    }
}
