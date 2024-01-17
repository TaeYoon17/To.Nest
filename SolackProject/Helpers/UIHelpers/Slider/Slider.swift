//
//  Slider.swift
//  SolackProject
//
//  Created by 김태윤 on 1/18/24.
//

import Foundation
import UIKit
import SwiftUI
final class Slider<T: ObservableObject>:UIHostingController<SliderView<T>>{
    init(_ sliderVM: SliderVM,_ sideVM: T){
        let view = SliderView(sliderVM:sliderVM,sideVM: sideVM)
        super.init(rootView: view)
        self.view.backgroundColor = .clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
struct SliderView<T: ObservableObject>: View{
    @ObservedObject var sliderVM: SliderVM
    @ObservedObject var sideVM: T
    @State private var offsetX:CGFloat = 0
    var body:some View{
        ZStack{
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
            WorkSpaceMainView().environmentObject(sideVM)
        }
        .offset(x:offsetX)
        .simultaneousGesture(DragGesture().onChanged({ value in
            let x = value.translation.width
            if x > 0 {return}
            offsetX = x
        }).onEnded({ value in
            if value.predictedEndLocation.x < 0 || value.translation.width < -200{
                withAnimation { offsetX = value.translation.width }
                sliderVM.endedSlider.onNext(false)
                return
            }
            offsetX = 0
        })).onAppear(){
            offsetX = 0
        }
    }
}

