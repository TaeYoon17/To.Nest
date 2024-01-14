//
//  NetworkManager.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
typealias NM = NetworkManager
final class NetworkManager{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    static let accessExpireSeconds:Double = 60 * 60
    static let shared = NetworkManager()
    let baseInterceptor = BaseInterceptor()
    var authInterceptor:AuthenticatorInterceptor = .init()
    var customValidation = { (request:URLRequest?, response:HTTPURLResponse, data:Data?) -> Result<Void, Error> in
        let error = AFError.responseValidationFailed(reason: Alamofire.AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 400))
        if response.statusCode == 200{
            return .success(())
        }
        if let data, let errorData = try? JSONDecoder().decode(ErrorCode.self, from: data){
            print(errorData)
            if let code = CommonFailed(rawValue: errorData.errorCode){
                switch code{
                case .expiredAccess,.tokenAuthFailed:
                    return .failure(error)
                default: return .success(())
                }
            }else{
                return.success(())
            }
        }
        return .failure(error)
    }
//    func getThumbnail(_ urlStr: String) -> Data{
//        let router = ImageRouter.get(urlStr: urlStr)
//        AF.request(router,interceptor: baseInterceptor).responseString { res in
//            switch res.result{
//            case .success(let str):
//                print("썸네일 가져오기 성고")
//            case .failure(let error):
//                print("썸네일 문제!!")
//            }
//        }
//    }
}

