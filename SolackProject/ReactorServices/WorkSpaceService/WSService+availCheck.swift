//
//  WSService+availCheck.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import Foundation
import RxSwift
extension WorkSpaceService{
    func authValidCheck(error: Error)->Bool{
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
