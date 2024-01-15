//
//  ToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import UIKit
import Toast
protocol ToastType{
    var contents:String { get }
    var getColor:UIColor{ get }

}
extension ToastType{
    static func ==(lhs: any ToastType, rhs: any ToastType) -> Bool {
        return lhs.contents == rhs.contents
    }
}
protocol Toastable:UIViewController{
    var isShowKeyboard: CGFloat? { get set}
    var toastY: CGFloat {get}
    var toastHeight:CGFloat {get set}
    func toastUp(type: any ToastType)
    func defaultStyle(type: ToastType) -> ToastStyle
}
extension Toastable{
    func defaultStyle(type: ToastType) -> ToastStyle{
        var style = ToastStyle()
        style.messageFont = FontType.body.get()
        style.cornerRadius = 8
        style.messageColor = .white
        style.verticalPadding = 9
        style.horizontalPadding = 16
        style.backgroundColor = type.getColor
        return style
    }
    func toastUp(type: any ToastType){
        var style = defaultStyle(type: type)
        let toast = try! navigationController!.view.toastViewForMessage(type.contents, title: nil, image: nil, style: style)
        let radiusHeight = toast.frame.height / 2
        self.toastHeight = toast.frame.height
        let center:CGPoint = .init(x: UIScreen.current!.bounds.midX, y: toastY)
        navigationController?.view.showToast(toast, duration: ToastManager.shared.duration,point: center,completion: nil)
    }
}
