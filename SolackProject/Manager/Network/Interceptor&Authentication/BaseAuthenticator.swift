//
//  Authenticator.swift
//  lslpProject
//
//  Created by 김태윤 on 2023/11/24.
//

import Foundation
import Alamofire
final class BaseAuthenticator: Authenticator{
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    typealias Credential = AuthCredential
    
    // Interceptor에서 본 추가할 헤더 코드들을 넣는 메서드와 같음
    // inout으로 URLRequest에 헤더 추가시 바로 적용된다.
    func apply(_ credential: Credential, to urlRequest: inout URLRequest) {
        print("BaseAuthenticator apply")
        urlRequest.addValue(API.key, forHTTPHeaderField: "SesacKey")
        urlRequest.addValue(credential.accessToken, forHTTPHeaderField: "Authorization")
    }
    // 인터셉터에서는 요청 결과를 419 코드로 받으면 요청을 재검사할 필요가 있다고 본다.
    func didRequest(_ urlRequest: URLRequest, with response: HTTPURLResponse, failDueToAuthenticationError error: Error) -> Bool {
        
        print("인터셉트 재검사 코드")
        return response.statusCode == 400
    }
    // 요청한 결과에 대해서 다시한번 재확인
    func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: Credential) -> Bool {
        return credential.accessToken == self.accessToken
    }
    func refresh(_ credential: Credential, for session: Session, completion: @escaping (Result<Credential, Error>) -> Void) {
        Task{
            do{
                let val = try await NM.shared.refresh(session: session)
                self.accessToken = val.accessToken
                let expiration = Date(timeIntervalSinceNow: NetworkManager.accessExpireSeconds)
                let newCredential = AuthCredential(expiration: expiration)
                print("리프레시 성공!")
                completion(.success(newCredential))
            }catch let fail where fail is AuthFailed{ // 인증 실패(리프레시)를 제외하고 원래 로직을 따라가게 함...
                print("리프레시 실패!!")
                completion(.failure(fail as! AuthFailed))
            }catch let commonFailed where commonFailed is CommonFailed{
                print("리프레시 실패2!!: \(commonFailed)")
//                completion(.failure(commonFailed))
//                completion(.success(<#T##Credential#>))
                completion(.success(credential))
            }catch{
                print("리프레시 실패3!!: \(error)")
//                completion(.failure(error))
                completion(.success(credential))
            }
        }
    }
}

