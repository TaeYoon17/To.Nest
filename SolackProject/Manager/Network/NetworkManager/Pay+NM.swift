//
//  Pay+NM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import Foundation
import Alamofire

extension NM{
    func itemList() async throws -> [PayAmountResponse]{
        let router = PayRouter.itemList
        return try await withCheckedThrowingContinuation { [weak self ] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router, interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: PayFailed.self, result: [PayAmountResponse].self, res: res, continuation: continuation)
            }
        }
    }
    func payValidation(imp:String,merchant:String) async throws -> BillResponse{
        let router = PayRouter.validation(imp: imp, merchant: merchant)
        return try await withCheckedThrowingContinuation { [weak self ] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router, interceptor: authInterceptor).validate(customValidation).response {[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                self.generalResponse(err: PayFailed.self, result: BillResponse.self, res: res, continuation: continuation)
            }
        }
    }
}
