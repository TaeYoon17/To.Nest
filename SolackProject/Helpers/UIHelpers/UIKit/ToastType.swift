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
protocol Toastable:UIViewController{
    func toastUp(type: ToastType)
}
