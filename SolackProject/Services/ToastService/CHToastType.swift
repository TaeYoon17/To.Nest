//
//  CHToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/15/24.
//

import Foundation
import UIKit
enum CHToastType:ToastType{
    case double,complete,isNotChannelAdmin
    var contents: String{
        switch self{
        case .complete: "채널이 생성되었습니다."
        case .double: "워크스페이스에 이미 있는 채널 이름입니다. 다른 이름을 입력해주세요."
        case .isNotChannelAdmin: "채널관리자가 아닙니다."
        }
    }
    var getColor: UIColor{
        UIColor.accent
    }
}
