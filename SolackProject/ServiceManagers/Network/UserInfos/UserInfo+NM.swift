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
}
