//
//  ButtonConfiration.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import Foundation
import UIKit
extension UIButton{
    var config: ButtonConfigure{
        ButtonConfigure(button: self)
    }
    
}
struct ButtonConfigure{
    private let configuration: UIButton.Configuration
    private weak var button: UIButton!
    init(button: UIButton){
        self.button = button
        self.configuration = UIButton.Configuration.plain()
    }
    private init(configuration: UIButton.Configuration,_ btn:UIButton){
        self.configuration = configuration
        self.button = btn
    }
    
    func text(_ text: String,font: FontType)->Self{
        var config = configuration
        config.titlePadding = 0
        config.attributedTitle = text.attr(type: font)
        config.imagePadding = 0
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        return ButtonConfigure(configuration: config, button)
    }
    func cornerRadius(_ number:CGFloat) -> Self {
        var config = configuration
        config.background.cornerRadius = number
        return ButtonConfigure(configuration: config, button)
    }
    func backgroundColor(_ color: UIColor) -> Self{
        var config = configuration
        config.background.backgroundColor = color
        return ButtonConfigure(configuration: config, button)
    }
    func foregroundColor(_ color: UIColor) -> Self{
        var config = configuration
        config.baseForegroundColor = color
        return ButtonConfigure(configuration: config, button)
    }
    func apply(){
        button.configuration = configuration
    }
}
