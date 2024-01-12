//
//  WS+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import Alamofire
extension NM{
    func createWS(_ info:WSInfo) async throws -> WSResponse{
        let router = WSRouter.create(info: info)
        return try await withCheckedThrowingContinuation { continutaion in
            AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: self.authInterceptor)
                .validate()
                .uploadProgress { progress in
                    print("\(progress)")
                }
                .response {[weak self] res in
                    guard let self else{
                        continutaion.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: WSFailed.self, result: WSResponse.self, res: res, continuation: continutaion)
                }
        }
    }
    func checkAllWS() async throws -> [WSResponse]{
        let router = WSRouter.check(.myAll)
        return try await withCheckedThrowingContinuation { contiuation in
            AF.request(router,interceptor: self.authInterceptor)
                .validate()
                .response{ [weak self] res in
                    guard let self else{
                        contiuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: WSFailed.self, result: [WSResponse].self, res: res, continuation: contiuation)
                }
        }
    }
}
