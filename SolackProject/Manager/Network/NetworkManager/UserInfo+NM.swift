//
//  Manager+UserInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
import RxSwift

/*
 wow@gmail.com
 Aa123@@@qa
 토스트
 010-1111-2222
 */
extension NetworkManager{
    func signUp(_ info : SignUpInfo) async throws -> SignResponse{
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(UserRouter.signUp(info: info),interceptor: self.baseInterceptor).response {[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                signResponse(res: res, continuation: continuation)
            }
        }
    }
    func emailCheck(_ email:String) -> Observable<Bool>{
        Observable.create {[weak self] observer -> Disposable in
            guard let self else {
                observer.onError(Errors.API.FailFetchToken)
                return Disposables.create()
            }
            AF.request(UserRouter.validation(email: email),interceptor: self.baseInterceptor).response { res in
                switch res.result{
                case .success(let val):
                    
                    guard let code = res.response?.statusCode else{
                        observer.onError(Errors.API.FailFetchToken)
                        break
                    }
                    if code == 400,let val,let errorData = try? JSONDecoder().decode(ErrorCode.self, from: val){
                        if errorData.errorCode == "E12"{
                            observer.onNext(false)
                            observer.onCompleted()
                        }else{
                            observer.onError(Errors.API.FailFetchToken)
                            observer.onCompleted()
                        }
                    }
                    else if code == 200{
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                case .failure(let error):
                    print("이메일 중복 검사 실패 \(error)")
                    observer.onError(error)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    func signIn<T:SignInBody>(type:SignInType,body:T) async throws -> SignResponse {
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(UserRouter.signIn(type: type, body: body),interceptor: baseInterceptor).response {[weak self] res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                signResponse(res: res, continuation: continuation)
                return
            }
        }
    }
    func updateMyInfo(nickName:String? = nil,phone:String? = nil) async throws -> MyInfo{
        let router = UserRouter.putMy(nickName: nickName, phone: phone)
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router, interceptor: authInterceptor).response { res in
                self.generalResponse(err: AuthFailed.self, result: MyInfo.self, res: res, continuation: continuation)
            }
        }
    }
    func checkUser(userID:Int) async throws -> UserResponse{
        let router = UserRouter.getUser(id: "\(userID)")
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router, interceptor: authInterceptor).response { res in
                self.generalResponse(err: AuthFailed.self, result: UserResponse.self, res: res, continuation: continuation)
            }
        }
    }
    func updateMyInfo(profileImage:Data?) async throws -> MyInfo{
        let router = UserRouter.putMyImage(image: profileImage)
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.upload(multipartFormData: router.multipartFormData, with: router,interceptor: authInterceptor)
                .response{ res in
                self.generalResponse(err: AuthFailed.self, result: MyInfo.self, res: res, continuation: continuation)
            }
        }
    }
    func signOut() async throws -> Bool{
        let router = UserRouter.signOut
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(router,interceptor: authInterceptor).validate(customValidation).response { res in
                if res.response?.statusCode == 200{
                    continuation.resume(returning: true)
                    return
                }
                switch res.result{
                case .success(let val):
                    if let val,let errorData = try? JSONDecoder().decode(ErrorCode.self, from: val){
                        if let failType = CommonFailed(rawValue: errorData.errorCode){
                            continuation.resume(throwing: failType)
                            return
                        }else{
                            continuation.resume(throwing: Errors.API.FailFetchToken)
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
    }
}
// 결과값 에러처리
extension NetworkManager{
    fileprivate func signResponse(res:AFDataResponse<Data?>,continuation:CheckedContinuation<SignResponse, Error>) {
        switch res.result{
        case .success(let val):
            guard let code = res.response?.statusCode else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            if let val,let errorData = try? JSONDecoder().decode(ErrorCode.self, from: val){
                if let failType = SignFailed(rawValue: errorData.errorCode){
                    continuation.resume(throwing: failType)
                    return
                }else if let failType = CommonFailed(rawValue: errorData.errorCode){
                    continuation.resume(throwing: failType)
                    return
                }else{
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
            }
            else if code == 200,let val,let data = try? JSONDecoder().decode(SignResponse.self, from: val){
                print("성공성공")
                continuation.resume(returning: data)
                return
            }else{
                print("값 반환 이상이상")
            }
        case .failure(let error):
            continuation.resume(throwing: error)
            return
        }
    }
    func generalResponse<Err:FailedProtocol,Response:Decodable>(err: Err.Type, result: Response.Type,res: AFDataResponse<Data?>,continuation: CheckedContinuation<Response,Error>){
        switch res.result{
        case .success(let val):
            guard let code = res.response?.statusCode else{
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            if let val,let errorData = try? JSONDecoder().decode(ErrorCode.self, from: val){
                if let failType = err.converter(val: errorData.errorCode){
                    continuation.resume(throwing: failType)
                    return
                }else if let failType = CommonFailed.converter(val: errorData.errorCode){
                    print(failType)
                    continuation.resume(throwing: failType)
                    return
                }else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
            }
            else if code == 200,let val,let data = try? JSONDecoder().decode(Response.self, from: val){
                continuation.resume(returning: data)
                return
            }
        case .failure(let error):
            print("여기로 떨어져 벌임...")
            switch error{
            case .requestRetryFailed(retryError: let autherror, originalError: _):
                continuation.resume(throwing: autherror)
            default: continuation.resume(throwing: error)
            }
            return
        }
        continuation.resume(throwing: Errors.API.FailResponseDataDecoding)
    }
}
