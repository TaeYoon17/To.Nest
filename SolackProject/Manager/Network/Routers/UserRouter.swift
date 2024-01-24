//
//  UserRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
enum UserRouter: URLRequestConvertible{
    case signUp(info:SignUpInfo),signIn(type:SignInType,body:SignInBody),validation(email:String)
    case deviceToken(String)
    case signOut,getMy,getUser(id:String)
    case putMy,putMyImage
    static private let baseURL = URL(string: API.baseURL)
    var endPoint: String{
        switch self{
        case .signUp:
            return "/v1/users/join"
        case .signIn(let type,_):
            let v = switch type{
                case .email: "/v2"
                default: "/v1"
            }
            return "\(v)/users/login\(type.endPoint)"
        case .validation:
            return "/v1/users/validation/email"
        case .deviceToken:
            return "/v1/users/deviceToken"
        case .signOut:
            return "/v1/users/logout"
        case .getMy,.putMy:
            return "/v1/users/my"
        case .getUser(id: let id):
            return "/v1/users/my/\(id)"
        case .putMyImage:
            return "/v1/users/my/image"
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
        case .deviceToken(let deviceToken):
            var params = Parameters()
            params["deviceToken"] = deviceToken
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
        parameters["deviceToken"] = deviceToken
        return parameters
    }
}
extension EmailInfo:SignInBody{
    func getParameter() -> Alamofire.Parameters {
        var params = Parameters()
        params["email"] = email
        params["password"] = password
        @DefaultsState(\.deviceToken) var deviceToken
        params["deviceToken"] = deviceToken
        return params
    }
}
extension KakaoInfo:SignInBody{
    func getParameter() -> Parameters {
        var params = Parameters()
        params["oauthToken"] = oauthToken
        @DefaultsState(\.deviceToken) var deviceToken
        params["deviceToken"] = deviceToken
        return params
    }
}

extension AppleInfo:SignInBody{
    func getParameter() -> Parameters {
        var params = Parameters()
        params["idToken"] = idToken
        params["nickname"] = nickName
        @DefaultsState(\.deviceToken) var deviceToken
        params["deviceToken"] = deviceToken
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
