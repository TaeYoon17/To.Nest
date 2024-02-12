//
//  WS_Member+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/10/24.
//

import Foundation
import Alamofire
//MARK: -- 워크스페이스 멤버용 API
/// 1. 특정 워크스페이스 멤버들 정보 확인
/// 2. 워크스페이스에 회원 초대
/// 3. 워크스페이스 관리자 변경
extension NM{
    func checkWSMembers(_ wsID: Int) async throws -> [UserResponse]{
        let router = WSRouter.check(.memberAll(id: wsID))
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else{
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: WSFailed.self, result: [UserResponse].self, res: res, continuation: continuation)
            }
        }
    }
    func inviteWS(_ wsID:Int,email:String) async throws -> UserResponse{
        let router = WSRouter.invite(wsID: wsID, email: email)
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else{
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: WSFailed.self, result: UserResponse.self, res: res, continuation: continuation)
            }
        }
    }
    func adminChangeWS(wsID:Int, userID: Int) async throws -> WSResponse{
        let router = WSRouter.adminChange(wsID: wsID, userID: userID)
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else{
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: WSFailed.self, result: WSResponse.self, res: res, continuation: continuation)
            }
        }
    }
}
