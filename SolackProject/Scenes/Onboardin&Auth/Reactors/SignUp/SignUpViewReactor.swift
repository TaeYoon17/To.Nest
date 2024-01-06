//
//  SignUpViewReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import Foundation
import ReactorKit
import RxSwift

enum SignUpToastType{
    case emailValidataionError
    case vailableEmail
    case alreadyAvailable
    case nickNameCondition
    case phoneCondition
    case invalidateCheckPassword
    case other
    var contents:String{
        switch self{
        case .emailValidataionError: "이메일 형식이 올바르지 않습니다."
        case .vailableEmail: "사용 가능한 이메일입니다."
        case .alreadyAvailable: "사용 가능한 이메일입니다."
        case .nickNameCondition: "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
        case .phoneCondition: "10~11자리 숫자"
        case .invalidateCheckPassword: "작성하신 비밀번호가 일치하지 않습니다."
//            "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
        case .other: "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
}
enum SignUpFieldType{
    case email
    case nickname
    case phone
    case pw
}
class SignUpViewReactor: Reactor{
    var initialState: State = State()
    let provider: ServiceProviderProtocol
    var info = SignUpInfo()

    enum Action{
        case setEmail(String)
        case setNickname(String)
        case setPhone(String)
        case dobuleCheck
        case setSecret(String)
        case setCheckSecret(String)
        case signUpCheck
    }
    enum Mutation{
        case setEmail(String)
        case setNickname(String)
        case setPhone(String)
        case doubleCheck(Bool)
        case setSecret(String)
        case setCheckSecret(String)
        case setSignUpToast(SignUpToastType?)
        case validationFailedType(SignUpFieldType)
    }
    struct State{
        var email:String = ""
        var nickName:String = ""
        var secret:String = ""
        var checkSecret:String = ""
        var phone:String = ""
        var isEmailChecked:Bool = false
        var nickNameIsAvailable:Bool = false
        var signUpToast:SignUpToastType? = nil
    }
    init(provider: ServiceProviderProtocol){
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .setEmail(let email):
            if self.info.email != email{
                self.info.email = email
                return Observable.concat([
                    .just(.setEmail(email)),
                    .just(.doubleCheck(false))
                ])
            }else{return Observable.concat([]) }
        case .setNickname(let name):
            self.info.nick = name
            return Observable.concat([
                .just(.setNickname(name))
            ])
        case .setPhone(let phone):
            let convertedNumber = phone.convertToPhoneNumber()
            return Observable.concat([.just(.setPhone(convertedNumber))])
        case .dobuleCheck:
            guard validationEmail() else{
                print("failed validation Email")
                return Observable.concat([
                    .just(.setSignUpToast(.emailValidataionError)),
                    .just(.setSignUpToast(nil)).delay(.nanoseconds(100), scheduler: MainScheduler.instance)
                ])
            }
            let check = NM.shared.emailCheck(info.email)
            let doubleCheck = check.map{Mutation.doubleCheck($0)}
            let toast = check.map{ Mutation.setSignUpToast($0 ? .vailableEmail : .emailValidataionError) }
            return Observable.concat([
                doubleCheck,
                toast.delay(.nanoseconds(100), scheduler: MainScheduler.instance),
                .just(.setSignUpToast(nil)).delay(.nanoseconds(100), scheduler: MainScheduler.instance)
            ])
        case .setSecret(let secret):
            return Observable.concat([
                .just(.setSecret(secret))
            ])
        case .setCheckSecret(let secret):
            return Observable.concat([
                .just(.setCheckSecret(secret))
            ])
        case .signUpCheck:
            var arrState:[Observable<SignUpViewReactor.Mutation>] = []
            var arr:[Observable<SignUpViewReactor.Mutation>] = []
            if !validationNick(){
                arrState.append(.just(.validationFailedType(.nickname)))
                arr.append(.just(.setSignUpToast(.nickNameCondition)).delay(.seconds(1), scheduler: MainScheduler.asyncInstance))
            }
            if arr.isEmpty{
                // 회원가입 진행
                return Observable.concat([
                ])
            }else{ return Observable.concat(arr) }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setEmail(let email):
            state.email = email
        case .setNickname(let nick):
            state.nickName = nick
        case .setPhone(let phone):
            state.phone = phone
        case .doubleCheck(let valiEmail):
            state.isEmailChecked = valiEmail
        case .setSecret(let secret):
            state.secret = secret
        case .setCheckSecret(let checkSecret):
            state.checkSecret = checkSecret
        case .setSignUpToast(let type):
            state.signUpToast = type
        case .validationFailedType(let type):
            switch type{
            case .email: break
            case .nickname: break
            case .phone: break
            case .pw: break
            }
        }
        return state
    }
}
extension SignUpViewReactor{
    func validationEmail()->Bool{
        let emailRegex = #"@.*\.com"#
        do{
            let val = try Regex(emailRegex)
            return self.info.email.contains(val)
        }catch{
            return false
        }
    }
    func validationNick()->Bool{
        0 < self.info.nick.count && self.info.nick.count <= 30
    }
}
extension String{
    func convertToPhoneNumber()->(String){
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
