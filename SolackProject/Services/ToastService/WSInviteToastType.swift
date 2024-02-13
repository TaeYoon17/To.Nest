//
//  WSInviteToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 2/4/24.
//

import Foundation
import UIKit
typealias WSInviteToastType = WorkSpaceInviteToastType
enum WorkSpaceInviteToastType: ToastType{
    var contents: String{
        switch self{
        case .unknown: "알 수 없는 에러입니다"
        case .notAuthority: "워크스페이스 관리자만 워크스페이스 멤버를 초대할 수 있습니다."
        case .emailFailed: "올바른 이메일을 입력해주세요. "
        case .notUser: "회원 정보를 찾을 수 없습니다."
        case .doubled: "이미 워크스페이스에 소속된 팀원이에요."
        case .inviteSuccess: "멤버를 성공적으로 초대했습니다."
        }
    }
    var getColor: UIColor{
        switch self{
        case .emailFailed,.notAuthority,.unknown,.notUser,.doubled: UIColor.error
        case .inviteSuccess: UIColor.accent
        }
    }
    case unknown,notAuthority,emailFailed,notUser,doubled,inviteSuccess
}
