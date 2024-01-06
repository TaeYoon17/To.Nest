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
enum SignUpFailed:String, Error{
    case doubled = "E12"
    case wrong = "E11"
}
extension NetworkManager{
    func signUp(_ info : SignUpInfo) async throws -> SignUpResponse{
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(UserRouter.signUp(info: info),interceptor: self.baseInterceptor).response { res in
                switch res.result{
                case .success(let val):
                    guard let code = res.response?.statusCode else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                        return
                    }
                    if code == 400,let val,let errorData = try? JSONDecoder().decode(DoubleErrorCode.self, from: val){
                        if let failType = SignUpFailed(rawValue: errorData.errorCode){
                            continuation.resume(throwing: failType)
                        }else{
                            continuation.resume(throwing: Errors.API.FailFetchToken)
                        }
                    }
                    else if code == 200,let val,let data = try? JSONDecoder().decode(SignUpResponse.self, from: val){
                        continuation.resume(returning: data)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
        func signUp(info: SignUpInfo) -> Observable<SignUpResponse>{
            Observable.create { [weak self] observer -> Disposable in
                guard let self else{
                    observer.onError(Errors.API.FailFetchToken)
                    return Disposables.create()
                }
                AF.request(UserRouter.signUp(info: info),interceptor: self.baseInterceptor).response { res in
                    switch res.result{
                    case .success(let val):
                        guard let code = res.response?.statusCode else{
                            observer.onError(Errors.API.FailFetchToken)
                            observer.onCompleted()
                            break
                        }
                        if code == 400,let val,let errorData = try? JSONDecoder().decode(DoubleErrorCode.self, from: val){
                            if let failType = SignUpFailed(rawValue: errorData.errorCode){
                                observer.onError(failType)
                            }else{
                                observer.onError(Errors.API.FailFetchToken)
                            }
                            observer.onCompleted()
                        }
                        else if code == 200,let val,let data = try? JSONDecoder().decode(SignUpResponse.self, from: val){
                            observer.onNext(data)
                            observer.onCompleted()
                        }
                    case .failure(let error):
                        observer.onError(error)
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
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
    
    func signIn<T:SignInBody>(type:SignInType,body:T) async throws {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(UserRouter.signIn(type: type, body: body),interceptor: baseInterceptor).responseString { res in
                switch res.result{
                case .success(let value):
                    print("로그인!! \(value)")
                    if res.response?.statusCode ?? 0 == 200{
                        continuation.resume(returning: ())
                    }else{
                        continuation.resume(throwing: Errors.API.FailFetchToken)
                    }
                case .failure(let error):
                    print("로그인 실패")
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
