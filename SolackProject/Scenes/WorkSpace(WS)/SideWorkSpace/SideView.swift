//
//  SideView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift
import Combine
struct Side:View{
    @ObservedObject var vm: SideVM
    @GestureState var expand:CGFloat = 0
    @State var endPo:CGFloat = 0
    @State var nowPo:CGFloat = 0
    @State var isOpen:Bool = false
    var body:some View{
        ZStack(alignment:Alignment(horizontal: .leading, vertical: .center)){
            Color.gray.opacity(isOpen ? 0.85 : 0).ignoresSafeArea()
                .onTapGesture {
                    vm.isOpen = false
                }.zIndex(1)
            if isOpen{
                slider.frame(width: UIScreen.current!.bounds.width * 0.85 + expand)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                    .offset(x:endPo)
                    .offset(x:nowPo)
                    .gesture(DragGesture()
                        .onChanged({ value in
                            if value.translation.width < 0{
                                let width = value.translation.width
                                nowPo = width
                            }
                        })
                        .updating($expand, body: { val, state, transaction in
                                if val.translation.width > 0{
                                    withAnimation(.easeInOut(duration: 0.66)) {
                                        state = min(12,val.translation.width)
                                    }
                                }
                            }).onEnded({ value in
                                if value.predictedEndLocation.x < 0 || value.translation.width < -200{
                                    withAnimation { endPo = value.translation.width }
                                    vm.isOpen = false
                                    return
                                }
                                nowPo = 0
                            })
                    )
                    .zIndex(2)
                    .onDisappear(){ // 여기서 ViewController가 입력 처리하도록 바꿔줘야한다!!
                        Task{@MainActor in
                            try await Task.sleep(for: .seconds(0.3))
                            vm.closeAction.send(())
                        }
                    }
            }
        }.statusBar(hidden: true)
            .onReceive(vm.$isOpen, perform: { val in
                withAnimation(.easeOut(duration: 0.333)) {
                    isOpen = val
                    if val == false{
                        print("여기서 워크스페이스 사이드바 내려감")
                    }
                }
            })
            .statusBar(hidden:true)
    }
    var slider:some View{
        ZStack(alignment:Alignment(horizontal: .center, vertical: .center)){
            Color.gray1
                .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 24, style: .continuous))
                .ignoresSafeArea()
            VStack{
                Spacer()
                Color.white
                    .frame(height: 44)
                    .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 0, style: .continuous))
                    .ignoresSafeArea()
            }.ignoresSafeArea()
            VStack(spacing:0){
                HStack{
                    Text("워크스페이스").font(FontType.title1.font)
                    Spacer()
                }.frame(height: 44)
                    .padding(.leading,16)
                VStack(spacing:0){
                    Spacer()
                    WorkSpaceList()
                        .animation(nil)
                        .environmentObject(vm)
                    Spacer()
                    WorkSpaceBottomView()
                        .frame(height: 84)
                        .padding(.bottom,12)
                        .environmentObject(vm)
                }
                .background(.white)
                .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 1, topTrailingRadius: 0, style: .continuous))
            }
            
        }
    }
}

