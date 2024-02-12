//
//  Channel_Check+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/10/24.
//

import Foundation
import Alamofire
//MARK: -- 채널 조회 관련..
/// 1. 모든 내 채널 조회 -> 홈에서 볼 수 있는 것들
/// 2. 모든 채널 조회 -> 워크스페이스에서 존재하는 모든 채널
/// 3. 특정 채널 조회
/// 4. 특정 채널의 읽지 않은 채널 채팅 개수 조회
extension NM{
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
    func checkAllCH(wsID: Int) async throws -> [CHResponse] {
        let router = ChannelRouter.check(wsID: wsID, .all)
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
    func checkCH(wsID: Int, channelName:String) async throws -> CHResponse{
        let router = ChannelRouter.check(wsID: wsID, .specific(chName: channelName))
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response { [weak self] res in
                guard let self else{
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                generalResponse(err: CHFailed.self, result: CHResponse.self, res: res, continuation: continuation)
            }
        }
    }
    func checkUnreads(wsID: Int,channelName: String,date:Date?) async throws -> UnreadsChannelRes{
        let router = ChannelRouter.unreads(wsID: wsID, chName: channelName,lastDate: date)
        return try await withCheckedThrowingContinuation{ [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response { res in
                self.generalResponse(err: CHFailed.self, result: UnreadsChannelRes.self, res: res, continuation: continuation)
            }
        }
    }
}
