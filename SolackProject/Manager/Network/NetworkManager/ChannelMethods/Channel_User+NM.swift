//
//  Channel_User+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/10/24.
//

import Foundation
import Alamofire
extension NM{
    func checkCHUsers(wsID: Int, channelName:String) async throws -> [UserResponse]{
        let router = ChannelRouter.check(wsID: wsID, .members(chName: channelName))
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
                generalResponse(err: CHFailed.self, result: [UserResponse].self, res: res, continuation: continuation)
            }
        }
    }
    func changeCHAdmin(wsID:Int,channelName:String,userID:Int)async throws -> CHResponse{
        let router = ChannelRouter.changeAdmin(wsID: wsID, chName: channelName, userID: userID)
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router, interceptor: authInterceptor).validate(customValidation).response { [weak self] res in
                guard let self else{
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                generalResponse(err: CHFailed.self, result: CHResponse.self, res: res, continuation: continuation)
            }
        }
    }
}
