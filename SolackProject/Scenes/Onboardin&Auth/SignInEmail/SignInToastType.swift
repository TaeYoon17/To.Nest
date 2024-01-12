//
//  SignInToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
enum EmailSignInToastType:ToastType{
    case emailValidataionError
    case pwCondition
    case signInFailed
    case other
    case others([EmailSignInToastType])
    var contents:String{
        switch self{
        case .emailValidataionError:
            return "이메일 형식이 올바르지 않습니다."
        case .pwCondition:
            return "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
        case .signInFailed:
            return "이메일 또는 비밀번호가 올바르지 않습니다."
        case .other:
            return "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        case .others(let types):
            var str = ""
            for type in types {
                str += "• " + type.contents + "\n"
            }
            _ = str.popLast()
            return str
        }
    }
}
