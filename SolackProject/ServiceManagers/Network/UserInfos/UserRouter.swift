//
//  UserRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
enum UserRouter: URLRequestConvertible{
    case signUp(info:SignUpInfo),signIn(type:SignInType,body:SignInBody),validation(email:String),deviceToken
    case signOut,getMy,getUser(id:String)
    case putMy,putMyImage
    static private let baseURL = URL(string: API.baseURL+"/v1/users")
    var endPoint: String{
        switch self{
        case .signUp:
            "/join"
        case .signIn(let type,_):
            "/login\(type.endPoint)"
        case .validation:
            "/validation/email"
        case .deviceToken:
            "/deviceToken"
        case .signOut:
            "/logout"
        case .getMy,.putMy:
            "/my"
        case .getUser(id: let id):
            "/my/\(id)"
        case .putMyImage:
            "/my/image"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .signUp, .signIn, .validation,.deviceToken: .post
        case .signOut, .getMy, .getUser: .get
        case .putMy,.putMyImage: .put
        }
    }
    var parameters: Parameters{
        switch self{
        case .signUp(let userInfo): return userInfo.getParameter()
        case .validation(let email):
            var params = Parameters()
            params["email"] = email
            return params
        case .signIn(_,let body): return body.getParameter()
        case .putMy,.putMyImage:
            return Parameters()
        case .signOut,.getMy,.getUser: return Parameters()
        case .deviceToken:
            @DefaultsState(\.deviceToken) var deviceToken
            var params = Parameters()
            params["deviceToken"] = deviceToken ?? ""
            return params
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard var url = Self.baseURL?.appendingPathComponent(endPoint) else {
            print("hello world")
            return URLRequest(url: URL(string: "www.naver.com")!)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = self.method
        switch self{
        case .signOut,.getMy,.getUser: break
        default:
            urlRequest.httpBody = try? JSONEncoding.default.encode(urlRequest, with: parameters).httpBody
        }
        return urlRequest
//        URLRequest(url: URL(string: "www.naver.com")!)
    }
    
    
}
protocol SignInBody{
    func getParameter()->Parameters
}
extension SignUpInfo{
    func getParameter()->Parameters{
        var parameters = Parameters()
        parameters["email"] = email
        parameters["password"] = pw
        parameters["nickname"] = nick
        parameters["phone"] = phone
        @DefaultsState(\.deviceToken) var deviceToken
        parameters["deviceToken"] = deviceToken ?? ""
        
        return parameters
    }
}
extension EmailInfo:SignInBody{
    func getParameter() -> Alamofire.Parameters {
        var params = Parameters()
        params["email"] = email
        params["password"] = password
        @DefaultsState(\.deviceToken) var deviceToken
        params["deviceToken"] = deviceToken ?? ""
        return params
    }
}
extension KakaoInfo:SignInBody{
    func getParameter() -> Parameters {
        var params = Parameters()
        params["oauthToken"] = oauthToken
        @DefaultsState(\.deviceToken) var deviceToken
        params["deviceToken"] = deviceToken ?? ""
        return params
    }
}

extension AppleInfo:SignInBody{
    func getParameter() -> Parameters {
        var params = Parameters()
        params["idToken"] = idToken
        params["nickname"] = nickName
        @DefaultsState(\.deviceToken) var deviceToken
        params["deviceToken"] = deviceToken ?? ""
        return params
    }
}
extension SignInType{
    var endPoint:String{
        switch self{
        case .apple:"/apple"
        case .email:""
        case .kakao:"/kakao"
        }
    }
}
