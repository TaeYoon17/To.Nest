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
        if response.statusCode == 200{
            return .success(())
        }
        if let data, let _ = try? JSONDecoder().decode(ErrorCode.self, from: data){
            return .success(())
        }
        return .failure(AFError.responseValidationFailed(reason: Alamofire.AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: 400)))
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

