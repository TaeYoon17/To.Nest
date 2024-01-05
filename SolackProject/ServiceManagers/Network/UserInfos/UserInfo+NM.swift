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

extension NetworkManager{
    func signUp(_ val : SignUpInfo) async throws {
        AF.request(UserRouter.signUp(info: val), interceptor: baseInterceptor).responseString { res in
            switch res.result{
            case .success(let res):
                print("회원가입!!")
            case .failure(let error):
                print("회원가입 실패")
                print(error)
            }
            print(res.response?.statusCode)
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
    func emailDouble(_ email:String) async throws -> Bool{
        try await withCheckedThrowingContinuation { continuation in
            
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
