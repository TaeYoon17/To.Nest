//
//  Errors.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
enum Errors:Error{
    enum API:Error{
        case FailResponseDataDecoding
        case FailFetchToken
    }
    case compresstionFail
    case cachingEmpty
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
    case unknwonAccount = "E03"
    case lackCoin = "E21"
    case bad = "E11"
    case doubled = "E12"
    case nonExistData = "E13"
    case nonAuthority = "E14" // 워크스페이스 관리자만이 워크스페이스를 삭제할 수 있습니다!!
    case denyExitWS = "E15" // 워크스페이스 채널 중 관리자인 채널이 있습니다.
    static func converter(val: String) -> WorkSpaceFailed? {
        WorkSpaceFailed(rawValue: val)
    }
}
typealias CHFailed = ChannelFailed
enum ChannelFailed: String,FailedProtocol{
    case bad = "E11"
    case doubled = "E12"
    case nonExistData = "E13"
    case nonAuthority = "E14" // 채널 관리자만이 채널을 수정할 수 있습니다.
    case deny = "E15" // 요청 거절이용...
    static func converter(val: String) -> ChannelFailed? {
        ChannelFailed(rawValue: val)
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
enum MessageFailed: String, FailedProtocol{
    case badRequest = "E11"
    case nonExistData = "E13"
    static func converter(val: String) -> MessageFailed? {
        MessageFailed(rawValue: val)
    }
}
enum DMFailed: String,FailedProtocol{
    case nonExistData = "E13"
    static func converter(val: String) -> DMFailed? {
        DMFailed(rawValue: val)
    }
}
