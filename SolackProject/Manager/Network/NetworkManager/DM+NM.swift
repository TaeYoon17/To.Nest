//
//  DM+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import Alamofire
extension NM{
    func checkAllRooms(wsID: Int) async throws ->[DMRoomResponse]{
        let router = DMRouter.checkRoom(wsID: wsID)
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
                self.generalResponse(err: DMFailed.self, result: [DMRoomResponse].self, res: res, continuation: continuation)
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
            AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: DMFailed.self, result: DMResponse.self, res: res, continuation: continuation)
            }
        }
    }
    func checkDM(wsID:Int,userID:Int,date:Date?) async throws -> DMChatsResponse{
        let router = DMRouter.check(wsID: wsID, userID: userID, date: date)
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
                self.generalResponse(err: DMFailed.self, result: DMChatsResponse.self, res: res, continuation: continuation)
            }
        }
    }
    func unreadDM(wsID:Int,roomID:Int,date:Date?) async throws -> UnreadDMRes{
        let router = DMRouter.unread(wsID: wsID, roomID: roomID, date: date)
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
                self.generalResponse(err: DMFailed.self, result: UnreadDMRes.self, res: res, continuation: continuation)
            }
        }
    }
}


