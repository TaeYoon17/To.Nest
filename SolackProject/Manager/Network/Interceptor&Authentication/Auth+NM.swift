//
//  Auth+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import Alamofire
struct RefreshResponse:Codable{
    var accessToken: String
}

extension NetworkManager{
    func refresh(session: Session) async throws -> RefreshResponse{
        let router = AuthRouter.refresh(refreshToken: refreshToken, accessToken: accessToken)
        return try await withCheckedThrowingContinuation {[weak self ] continuation in
            guard let self else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            session.request(router,interceptor: baseInterceptor).response{[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                generalResponse(err: AuthFailed.self, result: RefreshResponse.self, res: res, continuation: continuation)
            }
        }
    }
}
