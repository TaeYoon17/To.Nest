//
//  Channel+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/23/24.
//

import Foundation
import Alamofire
extension NM{
    func createCH(wsID:Int,_ info:CHInfo) async throws -> CHResponse{
        let router = ChannelRouter.create(wsID: wsID, info: info)
        return try await withCheckedThrowingContinuation { contiuation in
            AF.request(router, interceptor: authInterceptor)
                .validate(customValidation)
                .response { [weak self] res in
                    guard let self else{
                        contiuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: CHFailed.self, result: CHResponse.self, res: res, continuation: contiuation)
                }
        }
    }
    func checkAllCH(wsID: Int) async throws -> [CHResponse] {
        let router = ChannelRouter.check(wsID: wsID, .allMy)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(router,interceptor: authInterceptor)
                .validate(customValidation)
                .response { [weak self] res in
                    guard let self else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: CHFailed.self, result: [CHResponse].self, res: res, continuation: continuation)
                }
        }
    }
    func checkAllMyCH(wsID: Int) async throws -> [CHResponse]{
        let router = ChannelRouter.check(wsID: wsID, .allMy)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(router,interceptor: authInterceptor)
                .validate(customValidation)
                .response { [weak self] res in
                    guard let self else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: CHFailed.self, result: [CHResponse].self, res: res, continuation: continuation)
                }
        }
    }
}
