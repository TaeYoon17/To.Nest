//
//  WSTostType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import UIKit
typealias WSToastType = WorkSpaceToastType
enum WorkSpaceToastType: ToastType{
    var contents: String{
        switch self{
        case .unknown: "알 수 없는 에러입니다."
        case .emptyData: "존재 하지 않는 워크스페이스 입니다."
        case .notAuthority: "권한이 없습니다."
        }
    }
    
    var getColor: UIColor{
        switch self{
        case .unknown,.emptyData,.notAuthority: UIColor.error
        }
    }
    
    case unknown,emptyData,notAuthority
}
