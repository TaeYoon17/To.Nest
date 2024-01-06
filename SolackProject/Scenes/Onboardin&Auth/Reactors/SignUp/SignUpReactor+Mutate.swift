//
//  SignUpReactor+Mutate.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
import ReactorKit
import RxSwift
extension SignUpViewReactor{
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .setEmail(let email):
            if self.info.email != email{
                self.info.email = email
                self.emailValided = false // 이메일 중복 확인 해야함
                return Observable.concat([
                    .just(.setEmail(email)),
                ])
            }else{return Observable.concat() }
        case .setNickname(let name):
            self.info.nick = name.convertToNickName()
            return Observable.concat([
                .just(.setNickname(name))
            ])
        case .setPhone(let phone):
            let convertedNumber = phone.convertToPhoneNumber()
            self.info.phone = convertedNumber
            return Observable.concat([.just(.setPhone(convertedNumber))])
        case .setSecret(let secret):
            self.info.pw = secret
            return Observable.concat([
                .just(.setSecret(secret))
            ])
        case .setCheckSecret(let secret):
            self.checkedPW = secret
            return Observable.concat([
                .just(.setCheckSecret(secret))
            ])
            // 이메일 중복 검사
        case .dobuleCheck:
            guard self.info.email.validationEmail() else{ // 이메일 유효성 검사
                self.emailValided = false
                return Observable.concat([
                    .just(.setSignUpToast(.emailValidataionError)),
                    .just(.setSignUpToast(nil)).delay(.nanoseconds(100), scheduler: MainScheduler.instance)
                ])
            }
            if validedEmailCache.contains(self.info.email){ // 이미 확인된 이메일인 경우
                self.emailValided = true
                return Observable.concat([
                    .just(.setSignUpToast(.vailableEmail)),
                    .just(.setSignUpToast(nil)).delay(.nanoseconds(100), scheduler: MainScheduler.instance)
                ])
            }else{ // 이메일 유효성 검사가 필요한 경우
                let check = NM.shared.emailCheck(info.email)
                let toast = check.map{ Mutation.setSignUpToast($0 ? .vailableEmail : .emailValidataionError) }
                // 이메일 유효성 검사 완료 후 사용 가능한 이메일
                check.bind(with: self) { owner, check in
                    if check{owner.validedEmailCache.insert(owner.info.email)}
                    owner.emailValided = check
                }.disposed(by: networkDisposeBag)
                return Observable.concat([
                    toast.delay(.nanoseconds(100), scheduler: MainScheduler.instance),
                    .just(.setSignUpToast(nil)).delay(.nanoseconds(100), scheduler: MainScheduler.instance)
                ])
            }
            // 회원가입 확인
        case .signUpCheck:
            var toasts:[SignUpToastType] = []
            var failedFields:[SignUpFieldType] = []
            if !emailValided{ // 이메일 중복확인이 되었는가
                toasts.append(.unCheckedValidation)
                failedFields.append(.email)
            }
            if !self.info.nick.validationNick(){ // 닉네임이 1글자 ~ 30 글자인가
                toasts.append(.nickNameCondition)
                failedFields.append(.nickname)
            }
            if !self.info.phone.validataionPhone(){ // 전화번호
                toasts.append(.phoneCondition)
                failedFields.append(.phone)
            }
            if !self.info.pw.validationPW(){ // 비밀번호 유효성 검사
                toasts.append(.pwCondition)
                failedFields.append(.pw)
            }
            if self.checkedPW != self.info.pw{ // 비밀번호 중복 검사
                toasts.append(.invalidateCheckPassword)
                failedFields.append(.pw)
            }
            guard toasts.isEmpty && failedFields.isEmpty else { // 위에 모든 유효성 검사 중 오류 발생
                return Observable.concat([
                    .just(.validationFailedTypes(failedFields)),
                    .just(.setSignUpToast(.others(toasts))).delay(.nanoseconds(100), scheduler: MainScheduler.instance),
                    .just(.setSignUpToast(nil))
                ])
            }
            print(info)
            provider.signUpService.signUp(info)
            return Observable.concat([
//                .just(.setSignUpToast(.other)),
//                .just(.setSignUpToast(nil)).delay(.nanoseconds(100), scheduler: MainScheduler.instance)
            ])
        }
    }
}
//MARK: -- Mutation 변경 확인 사항
 extension String{
     fileprivate func validationEmail()->Bool{
        let emailRegex = #"@.*\.com"#
        do{
            let val = try Regex(emailRegex)
            return self.contains(val)
        }catch{
            return false
        }
    }
     fileprivate func validationNick()->Bool{
        0 < self.count && self.count <= 30
    }
     fileprivate func validataionPhone()->Bool{
        if self.isEmpty {return true}
        guard self.prefix(2) == "01" else{ return false}
        let wow = self.replacingOccurrences(of: "-", with: "").count
        if wow < 10 || wow > 11 {return false}
        return true
    }
    func validationPW()->Bool{
        guard self.count >= 8 else {
            return false
        }
        let pwRegex =  "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[^a-zA-Z\\d]).+$"
        do{
            let val = try Regex(pwRegex)
            return self.contains(val)
        }catch{
            return false
        }
    }
    func convertToNickName()->String{
        guard self.count < 31 else {
            return String(self[startIndex..<index(startIndex, offsetBy: 31)])
        }
        return self
    }
    func convertToPhoneNumber()->String{
        guard self.count < 13 else {
            return String(self[startIndex..<index(startIndex, offsetBy: 13)])
        }
        
        var origin = self
        if let last = origin.last, last == "-"{
            _ = origin.popLast()
            return origin
        }
        origin = origin.replacingOccurrences(of: "-", with: "")
        var newOrigin = ""
        for i in 0..<origin.count{
            if i == 3 || i == 7{ newOrigin += "-" }
            newOrigin.append(origin[origin.index(origin.startIndex, offsetBy: i)])
        }
        return newOrigin
    }
}
