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
    func accessErrorHandler<T:FailedProtocol>(of: T.Type,_ error:Error,completion: (T?)->()){
        guard authValidCheck(error: error) else {
            AppManager.shared.userAccessable.onNext(false)
            return
        }
        completion(error as? T)
    }
    private func authValidCheck(error: Error)->Bool{
        print(error)
        if let auth = error as? AuthFailed{
            switch auth{
            case .isValid: return true // 로그인 필요 X
            default: return false // 재로그인 로직 돌리기
            }
        }
        return true
    }
}
extension AppManager{
    func initNavigationAppearances(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
