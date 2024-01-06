//
//  Manager+UserInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
import RxSwift
struct DoubleErrorCode:Decodable{
    let errorCode:String
}
/*
 wow@gmail.com
 Aa123@@@qa
 토스트
 010-1111-2222
 */
enum SignFailed:String, Error{
    case signUpDoubled = "E12" // 중복
    case signUpwrong = "E11" // 잘못됨
    case signInFailed = "E03" // 로그인 실패
}

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
                    print("이메일 중복 검사 성공!!")
                    guard let code = res.response?.statusCode else{
                        observer.onError(Errors.API.FailFetchToken)
                        break
                    }
                    if code == 400,let val,let errorData = try? JSONDecoder().decode(DoubleErrorCode.self, from: val){
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
        try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {
                continuation.resume(throwing: Errors.API.FailFetchToken)
                return
            }
            AF.request(UserRouter.signIn(type: type, body: body),interceptor: baseInterceptor).response {[weak self]res in
                guard let self else {
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                    return
                }
                signResponse(res: res, continuation: continuation)
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
            if code == 400,let val,let errorData = try? JSONDecoder().decode(DoubleErrorCode.self, from: val){
                if let failType = SignFailed(rawValue: errorData.errorCode){
                    continuation.resume(throwing: failType)
                }else{
                    continuation.resume(throwing: Errors.API.FailFetchToken)
                }
            }
            else if code == 200,let val,let data = try? JSONDecoder().decode(SignResponse.self, from: val){
                continuation.resume(returning: data)
            }
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}
