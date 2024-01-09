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
            if isVisible{
                view.superview?.superview?.backgroundColor = .gray.withAlphaComponent(0.666)
            }else{
                view.superview?.superview?.backgroundColor = .clear
            }
        }
        return view
    }    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

