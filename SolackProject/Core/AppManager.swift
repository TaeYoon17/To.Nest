//
//  AppManager.swift
//  SolackProject
//
//  Created by 김태윤 on 1/5/24.
//

import Foundation
import UIKit
import RxSwift
final class AppManager{
    static let shared = AppManager()
    let userAccessable = PublishSubject<Bool>()
    
}
