//
//  TransparentBackground.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
import UIKit

struct TransparentBackground: UIViewRepresentable {
    @Binding var isVisible:Bool
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.superview?.superview?.backgroundColor = .gray.withAlphaComponent(0.666)
            }
        }
        return view
    }    
    func updateUIView(_ uiView: UIView, context: Context) {
        if isVisible{
            uiView.superview?.superview?.backgroundColor = .gray.withAlphaComponent(0.666)
        }else{
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}

