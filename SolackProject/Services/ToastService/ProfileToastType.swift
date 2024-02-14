//
//  ProfileToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 2/14/24.
//

import UIKit
enum ProfileToastType:ToastType{
    case nicknameEditFailed
    case phoneNumberEditFailed
    case imageSuccess
    case imageError
    var contents: String{
        switch self{
        case .imageError: "프로필 이미지를 바꾸는데 실패했어요.\n다른 이미지로 시도해주세요."
        case .imageSuccess: "프로필 이미지를 바꾸는데 성공했어요."
        case .nicknameEditFailed: "닉네임 변경에 실패했습니다. 다시 입력해주세요."
        case .phoneNumberEditFailed: "연락처 변경에 실패했습니다. 다시 입력해주세요."
        }
    }
    var getColor: UIColor{
        switch self{
        case .imageError,.nicknameEditFailed,.phoneNumberEditFailed: UIColor.error
        case .imageSuccess: UIColor.accent
        }
    }
}
