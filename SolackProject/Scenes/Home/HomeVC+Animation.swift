//
//  HomeVC+Animation.swift
//  SolackProject
//
//  Created by 김태윤 on 1/17/24.
//

import Foundation
import UIKit

extension HomeVC{
    @objc func edgeSwipe(_ recognizer:UIScreenEdgePanGestureRecognizer){
        switch recognizer.state{
        case .began:
            sliderVM.sliderPresent.onNext(())
        case .changed:
            let x = recognizer.translation(in: self.view).x
            sliderVM.slider.onNext(x)
        case .ended:
            let velocity = recognizer.velocity(in: self.view).x
            let x = recognizer.translation(in: self.view).x
            if velocity > 100 || x > 200{
                sliderVM.endedSlider.onNext(true)
                return
            }else{
                sliderVM.endedSlider.onNext(false)
            }
        default: break
        }
    }
}
