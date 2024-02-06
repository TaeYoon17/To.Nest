//
//  DM+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import Alamofire
extension NM{
    func checkAllDM(wsID: Int) async throws ->[DMResponse]{
        let router = DMRouter.check(wsID: wsID)
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: DMFailed.self, result: [DMResponse].self, res: res, continuation: continuation)
            }
        }
    }
    func createDM(wsID:Int, roomID:Int,info:ChatInfo) async throws -> DMResponse{
        let router = DMRouter.create(wsID: wsID, roomID: roomID, dmInfo: info)
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: DMFailed.self, result: DMResponse.self, res: res, continuation: continuation)
            }
        }
    }
}


