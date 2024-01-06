//
//  SignUpToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
enum SignUpToastType{
    // 이메일 관련
    case emailValidataionError
    case vailableEmail
    case alreadyAvailable
    case unCheckedValidation
    //닉네임
    case nickNameCondition
    // 전화번호
    case phoneCondition
    // 비밀번호
    case pwCondition
    case invalidateCheckPassword
    case others([SignUpToastType])
    // 이미 가입
    case alreadySignedUp
    case other
    var contents:String{
        switch self{
        case .emailValidataionError: return "이메일 형식이 올바르지 않습니다."
        case .vailableEmail: return "사용 가능한 이메일입니다."
        case .alreadyAvailable: return "사용 가능한 이메일입니다."
        case .unCheckedValidation: return "이메일 중복 확인을 진행해주세요."
        case .nickNameCondition:return  "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
        case .phoneCondition:return "전화번호는 \"01\"부터 시작해 10~11자리 숫자로 설정해주세요."
        case .pwCondition:return  "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
        case .invalidateCheckPassword:return "작성하신 비밀번호가 일치하지 않습니다."
        case .other:return "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        case .others(let types):
            var str = ""
            for type in types {
                str += "• " + type.contents + "\n"
            }
            _ = str.popLast()
            return str
        case .alreadySignedUp:
            return "이미 가입된 회원입니다. 로그인을 진행해주세요."
        }
    }
}
