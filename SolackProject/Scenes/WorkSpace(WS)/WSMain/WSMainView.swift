//
//  WorkSpaceMainView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/18/24.
//

import Foundation
import SwiftUI
struct WorkSpaceMainView: View{
    @EnvironmentObject var vm: WSMainVM
    @State private var isReceived:Bool = false
    @State private var toast:ToastType? = nil
    @State private var toastHeight:CGFloat = 0
    var body: some View{
        ZStack{
            GeometryReader(content: { geometry in
                Color.clear.onAppear(){
                    self.toastHeight = geometry.frame(in: .local).maxY
                }
            })
            VStack(spacing:0){
                HStack{
                    Text("워크스페이스").font(FontType.title1.font)
                    Spacer()
                }.frame(height: 44)
                    .padding(.leading,16)
                VStack(spacing:0){
                    ZStack{
                        
                        VStack(spacing:0){
                            Spacer()
                            WorkSpaceList().animation(nil)
                                .environmentObject(vm)
                            Spacer()
                        }
                        if !isReceived{
                            Color.white.zIndex(100)
                        }
                    }
                    WorkSpaceBottomView()
                        .frame(height: 84)
                        .padding(.bottom,12)
                        .environmentObject(vm)
                }
                .onChange(of: vm.toastType, perform: { value in
                    guard let value else {return}
                    self.toast = value
                    Task{
                        try await Task.sleep(for: .microseconds(200))
                        self.vm.toastType = nil
                    }
                })
                .onChange(of: vm.isReceivedWorkSpaceList, perform: { newValue in
                    guard newValue else {return}
                    Task{@MainActor in
                        withAnimation { isReceived = newValue }
                    }
                })
                .background(.white)
                .clipShape(.rect(topLeadingRadius: 0,
                                 bottomLeadingRadius: 0,
                                 bottomTrailingRadius: 24,
                                 topTrailingRadius: 0,
                                 style: .continuous))
                
            }
        }.toast(type: $toast, alignment: .bottomLeading,position: .init(x: UIScreen.main.bounds.width / 2, y: toastHeight - 44))
    }
}
