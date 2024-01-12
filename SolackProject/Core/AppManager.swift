//
//  AppManager.swift
//  SolackProject
//
//  Created by 김태윤 on 1/5/24.
//

import Foundation
import UIKit
import RxSwift
let examineImage:[UIImage] = [.arKit,.metal,.C,.asyncSwift]
final class AppManager{
    static let shared = AppManager()
    let provider = ServiceProvider()
    let userAccessable = PublishSubject<Bool>()
}
