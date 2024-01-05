//
//  Manager+UserInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
extension NetworkManager{
    func signUp(_ val : SignUpInfo) async throws {
        AF.request(UserRouter.signUp(info: val), interceptor: baseInterceptor).responseString { res in
            switch res.result{
            case .success(let res):
                print("회원가입!!")
            case .failure(let error):
                print("회원가입 실패")
                print(error)
            }
            print(res.response?.statusCode)
        }
    }
    func signIn<T:SignInBody>(type:SignInType,body:T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(UserRouter.signIn(type: type, body: body),interceptor: baseInterceptor).responseString { res in
                switch res.result{
                case .success(let value):
                    print("로그인!! \(value)")
                    if res.response?.statusCode ?? 0 == 200{
                        continuation.resume(returning: ())
                    }else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                    }
                case .failure(let error):
                    print("로그인 실패")
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
