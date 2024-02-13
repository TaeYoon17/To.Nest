//
//  Chat+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import Alamofire
extension NM{
    func createChat(wsID:Int,chName:String,info: ChatInfo)async throws -> ChatResponse{
        let router = ChatRouter.create(wsID: wsID, chName: chName, info: info)
        return try await withCheckedThrowingContinuation { continuation  in
            AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: authInterceptor)
                .validate(customValidation)
                .uploadProgress{ progress in
                    print("\(progress)")
                }.response{ [weak self] res in
                    guard let self else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: MessageFailed.self, result: ChatResponse.self, res: res, continuation: continuation)
                }
        }
    }
    func checkChat(wsID:Int,chName:String,date:Date? = nil)async throws -> [ChatResponse]{
        let router = ChatRouter.check(wsID: wsID, chName: chName, cursorDate: date)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(router,interceptor: authInterceptor)
                .validate(customValidation)
                .response{ [weak self] res in
                    guard let self else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    generalResponse(err: MessageFailed.self, result: [ChatResponse].self, res: res, continuation: continuation)
                }
        }
    }
}
