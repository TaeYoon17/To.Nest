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
        case .unknown: "알 수 없는 에러입니다"
        case .emptyData: "존재 하지 않는 워크스페이스 입니다"
        case .notAuthority: "권한이 없습니다"
        case .lackCoin: "코인이 부족합니다"
        case .created: "워크스페이스가 생성되었습니다"
        case .edit: "워크스페이스가 편집되었습니다"
        case .delete: "워크스페이스가 삭제되었습니다"
        case .inviteNotManager: "워크스페이스 관리자만 팀원을 초대할 수 있어요.\n관리자에게 요청을 해보세요."
        }
    }
    
    var getColor: UIColor{
        switch self{
        case .unknown,.emptyData,.notAuthority,.lackCoin,.inviteNotManager: UIColor.error
        case .created,.edit,.delete: UIColor.accent
        }
    }
    
    case unknown,emptyData,notAuthority,lackCoin
    case created,edit,delete,inviteNotManager
}
