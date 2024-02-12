//
//  DMToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import Foundation
import UIKit
enum DMToastType:ToastType{
    case dmMemberError
    var contents: String{
        switch self{
        case .dmMemberError: "워크스페이스에 멤버가 존재하지 않습니다."
        }
    }
    var getColor: UIColor{
        UIColor.accent
    }
}
