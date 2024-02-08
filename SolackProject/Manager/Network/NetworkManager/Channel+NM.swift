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
    func editCH(wsID: Int,name:String,_ info:CHInfo) async throws -> CHResponse{
        
        let router = ChannelRouter.edit(wsID: wsID, chName: name, info: info)
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
    func deleteCH(wsID:Int, channelName:String) async throws -> Bool{
        let router = ChannelRouter.delete(wsID: wsID, chName: channelName)
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response { result in
                if 200 == result.response?.statusCode{
                    continuation.resume(returning: true)
                    return
                }
                switch result.result{
                case .success(let success):
                    if let data = success, let errorData = try? JSONDecoder().decode(ErrorCode.self, from: data){
                        if let failType = ChannelFailed.converter(val: errorData.errorCode){
                            continuation.resume(throwing: failType)
                        }else if let failType = CommonFailed.converter(val: errorData.errorCode){
                            print(failType)
                            continuation.resume(throwing: failType)
                            return
                        }else {
                            continuation.resume(throwing: Errors.API.FailFetchToken)
                            return
                        }
                    }
                case .failure(let error):
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                }
            }
        }
    }
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
