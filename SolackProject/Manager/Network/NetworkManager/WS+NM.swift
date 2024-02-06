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
                .validate(customValidation)
                .response {[weak self] res in
                    guard let self else{
                        continutaion.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: WSFailed.self, result: WSResponse.self, res: res, continuation: continutaion)
                }
        }
    }
    func editWS(_ info:WSInfo,wsID: String) async throws -> WSResponse{
        let router = WSRouter.edit(wsID: wsID, info: info)
        return try await withCheckedThrowingContinuation { continutaion in
            AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: self.authInterceptor)
                .uploadProgress { progress in
                    print("\(progress)")
                }
                .validate(customValidation)
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
                    print(res)
                    generalResponse(err: WSFailed.self, result: WSDetailResponse.self, res: res, continuation: continuation)
                }
        }
    }
    func deleteWS(_ wsID: Int) async throws -> Bool{
        let router = WSRouter.delete(wsID: wsID)
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else{
                continuation.resume(throwing: Errors.API.FailResponseDataDecoding)
                return
            }
            AF.request(router,interceptor: authInterceptor)
                .validate(customValidation)
                .response {[weak self] res in
                    guard let self else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    checkCompleteResponse(result: res, continuation: continuation)
                }
        }
    }
    func exitWS(_ wsID: Int) async throws -> Bool{
        let router = WSRouter.leave(wsID: wsID)
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else{
                continuation.resume(throwing: Errors.API.FailResponseDataDecoding)
                return
            }
            AF.request(router,interceptor: authInterceptor)
                .validate(customValidation)
                .response {[weak self] res in
                    guard let self else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    checkCompleteResponse(result: res, continuation: continuation)
                }
        }
    }
}
//MARK: -- 워크스페이스 멤버용 API
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
}
extension NM{
    fileprivate func checkCompleteResponse(result res:AFDataResponse<Data?>,continuation: CheckedContinuation<Bool, Error>){
        switch res.result{
        case .success(let data):
            if res.response?.statusCode == 200{
                    continuation.resume(returning: true)
                    return
            }
            if let data, let errorCode = try? JSONDecoder().decode(ErrorCode.self, from: data){
                if let common = CommonFailed(rawValue: errorCode.errorCode){
                    continuation.resume(throwing: common)
                    return
                }else if let ws = WSFailed(rawValue: errorCode.errorCode){
                    continuation.resume(throwing: ws)
                    return
                }
            }else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
        case .failure(let error):
            continuation.resume(throwing: Errors.API.FailFetchToken)
            return
        }
    }
}
