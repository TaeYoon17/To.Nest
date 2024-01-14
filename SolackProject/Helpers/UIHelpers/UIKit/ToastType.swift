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
    func toastUp(type: any ToastType)
}
