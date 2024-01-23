//
//  AuthInterceptor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import Alamofire
final class AuthenticatorInterceptor:RequestInterceptor{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    @DefaultsState(\.expiration) var expiration
    var requiresRefresh: Bool {
        return if let expiration{ Date() > expiration }else{ true }
    }
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        var request = urlRequest
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Accept")
        request.addValue(API.key, forHTTPHeaderField: "SesacKey")
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("들어와~~")
        guard requiresRefresh else{
            completion(.doNotRetry)
            return
        }
        Task{
            do{
                let val = try await NM.shared.refresh(session: session)
                expiration = Date(timeIntervalSince1970: NetworkManager.accessExpireSeconds)
                accessToken = val.accessToken
                print("리프레시 성공!")
                completion(.retry)
            }catch let fail where fail is AuthFailed{ // 인증 실패(리프레시)를 제외하고 원래 로직을 따라가게 함...
                print("리프레시 실패!!")
                accessToken = ""
                completion(.doNotRetryWithError(fail as! AuthFailed))
            }catch let commonFailed where commonFailed is CommonFailed{
                print("리프레시 실패2!!: \(commonFailed)")
                completion(.doNotRetryWithError(commonFailed))
            }catch{
                print("리프레시 실패3!!: \(error)")
                completion(.doNotRetry)
            }
        }
    }
    
}
