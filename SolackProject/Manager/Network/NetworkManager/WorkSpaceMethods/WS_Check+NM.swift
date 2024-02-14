//
//  WS_Check+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/10/24.
//

import Foundation
import Alamofire
// MARK: -- 워크스페이스 조회 관련
/// 1. 내가 속한 워크스페이스 조회
/// 2. 내가 속한 특정 워크스페이스 조회
extension NM{
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
    func checkWS(wsID:Int) async throws -> WSDetailResponse {
        let router = WSRouter.check(.my(id: "\(wsID)"))
        print(router)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(router,interceptor: self.authInterceptor)
                .validate(customValidation)
                .response{ [weak self] res in
                    guard let self else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: WSFailed.self, result: WSDetailResponse.self, res: res, continuation: continuation)
                }
        }
    }
}
