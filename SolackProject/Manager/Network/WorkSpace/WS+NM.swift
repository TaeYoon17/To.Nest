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
        print(#function)
        let router = WSRouter.create(info: info)
        return try await withCheckedThrowingContinuation { continutaion in
            AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: self.authInterceptor)
                .validate(customValidation)
                .uploadProgress { progress in
                    print("\(progress)")
                }
                .validate(statusCode:200..<600)
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
                .validate(customValidation)
                .response{ [weak self] res in
                    guard let self else{
                        contiuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: WSFailed.self, result: [WSResponse].self, res: res, continuation: contiuation)
                }
        }
    }
    func deleteWS(_ wsID: String) async throws{
        let router = WSRouter.delete(wsID: wsID)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(router,interceptor: self.authInterceptor)
                .validate(customValidation)
                .response { res in
                    if res.response?.statusCode == 200{
                        continuation.resume(returning: ())
                    }
                    switch res.result{
                    case .success(let data):
                        if let data, let errorCode = try? JSONDecoder().decode(ErrorCode.self, from: data){
                            if let common = CommonFailed(rawValue: errorCode.errorCode){
                                continuation.resume(throwing: common)
                            }else if let ws = WSFailed(rawValue: errorCode.errorCode){
                                continuation.resume(throwing: ws)
                            }
                        }
                    case .failure(let error):
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                    }
                }
            continuation.resume(throwing: Errors.API.FailResponseDataDecoding)
        }
    }
}
