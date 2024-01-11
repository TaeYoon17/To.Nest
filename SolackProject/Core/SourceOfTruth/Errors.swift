//
//  Errors.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
enum Errors:Error{
    enum API:Error{
        case FailFetchToken
    }
    case compresstionFail
}
protocol FailedProtocol:Error{
    static func converter(val:String) -> Self?
}
enum SignFailed:String,FailedProtocol{
    case signUpDoubled = "E12" // 중복
    case signUpwrong = "E11" // 잘못됨
    case signInFailed = "E03" // 로그인 실패
    static func converter(val: String) -> SignFailed? {
        SignFailed(rawValue: val)
    }
}
typealias WSFailed = WorkSpaceFailed
enum WorkSpaceFailed:String,FailedProtocol{
    case lackCoin = "E21"
    case bad = "E11"
    case doubled = "E12"
    static func converter(val: String) -> WorkSpaceFailed? {
        WorkSpaceFailed(rawValue: val)
    }
}
enum AuthFailed: String,FailedProtocol{
    case isValid = "E04"
    case unknownAccount = "E03"
    case expiredRefresh = "E06"
    case authFailed = "E02"
    static func converter(val: String) -> AuthFailed? {
        AuthFailed(rawValue: val)
    }
}
enum CommonFailed: String, FailedProtocol{
    case notAuthority = "E01"
    case noneRouter = "E97"
    case expiredAccess = "E05"
    case tokenAuthFailed = "E02"
    case unknwonUser = "E03"
    case overcall = "E98"
    case serverError = "E99"
    static func converter(val: String) -> CommonFailed? {
        CommonFailed(rawValue: val)
    }
}
//
//  Errors.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
enum Errors{
    enum API:Error{
        case FailFetchToken
        
    }
}
