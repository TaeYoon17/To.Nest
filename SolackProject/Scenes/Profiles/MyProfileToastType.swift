//
//  MyProfileToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/31/24.
//

import Foundation
import UIKit

enum MyProfileToastType: ToastType{
    case nicknameEditFailed
    case phoneNumberEditFailed
    var contents:String{
        switch self{
        case .nicknameEditFailed: "닉네임 변경에 실패했습니다. 다시 입력해주세요."
        case .phoneNumberEditFailed: "연락처 변경에 실패했습니다. 다시 입력해주세요."
        }
    }
    var getColor:UIColor{
        switch self{
        case .nicknameEditFailed,.phoneNumberEditFailed: UIColor.error
        }
    }
}
