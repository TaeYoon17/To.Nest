//
//  EmailSignInReactor+Mutate.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
import RxSwift

extension EmailSignInReactor{
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .setEmail(let email):
            info.email = email
            return Observable.concat([
                .just(.setEmail(email))
            ])
        case .setPassword(let pw):
            info.password = pw
            return Observable.concat([
                .just(.setPassword(pw))
            ])
        case .signIn:
            var toast:[EmailSignInToastType] = []
            var failedFields:[EmailSignInFieldType] = []
            if !self.info.email.validationEmail(){
                toast.append(.emailValidataionError)
                failedFields.append(.email)
            }
            if !self.info.password.validationPW(){
                toast.append(.pwCondition)
                failedFields.append(.password)
            }
            guard toast.isEmpty && failedFields.isEmpty else{
                return Observable.concat([
                    .just(.setErrorField(failedFields)),
                    .just(.setToast(.others(toast))).delay(.nanoseconds(100), scheduler: MainScheduler.instance),
                    .just(.setToast(nil))
                ])
            }
            // 검사 후...
            provider.signService.emailSignIn(info)
            return Observable.concat([
                .just(.setErrorField([]))
            ])
        }
    }
}
fileprivate extension String{
    func validationEmail()->Bool{
        let email = ".*\\.(com|co\\.kr|net).*"
        let emailRegex = ".*@.*"
        do{
            let val = try Regex(emailRegex)
            let one = try Regex(email)
            guard self.contains(one) else {return false}
            return self.contains(val)
        }catch{
            return false
        }
    }

}
