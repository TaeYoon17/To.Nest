//
//  SignUpToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
enum SignUpToastType{
    case emailValidataionError
    case vailableEmail
    case alreadyAvailable
    case nickNameCondition
    case phoneCondition
    case invalidateCheckPassword
    case other
    var contents:String{
        switch self{
        case .emailValidataionError: "이메일 형식이 올바르지 않습니다."
        case .vailableEmail: "사용 가능한 이메일입니다."
        case .alreadyAvailable: "사용 가능한 이메일입니다."
        case .nickNameCondition: "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
        case .phoneCondition: "10~11자리 숫자"
        case .invalidateCheckPassword: "작성하신 비밀번호가 일치하지 않습니다."
//            "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
        case .other: "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
}
