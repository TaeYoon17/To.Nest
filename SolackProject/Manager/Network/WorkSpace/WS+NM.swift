//
//  WS+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import Alamofire
extension NM{
//    func cws(_ info:WSInfo){
//        let router = WSRouter.create(info: info)
//        AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: self.authInterceptor).responseString { str in
//            print(str.request?.allHTTPHeaderFields)
//            
//            switch str.result{
//            case .success(let str): print(str)
//            case .failure(let err):print(err)
//            }
//        }
//    }
    func createWS(_ info:WSInfo) async throws -> WSResponse{
        let router = WSRouter.create(info: info)
        return try await withCheckedThrowingContinuation { continutaion in
            AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: self.authInterceptor)
                .uploadProgress { progress in
                    print("\(progress)")
                }
                .response {[weak self] res in
                    print("워크스페이스 생성 결과!!")
                guard let self else{
                    continutaion.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                generalResponse(err: WSFailed.self, result: WSResponse.self, res: res, continuation: continutaion)
            }
        }
    }
}
