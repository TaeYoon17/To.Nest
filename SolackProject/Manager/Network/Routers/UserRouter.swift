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
    case putMy(nickName:String?,phone:String?),putMyImage(image:Data?)
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
            return "/v1/users/\(id)"
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
        case .putMy(nickName: let nickName, phone: let phone):
            var params = Parameters()
            if let nickName{ params["nickname"] = nickName }
            if let phone{ params["phone"] = phone }
            return params
        case .putMyImage:
            return Parameters()
            
        case .signOut,.getMy,.getUser: return Parameters()
        case .deviceToken:
            @DefaultsState(\.deviceToken) var deviceToken
            var params = Parameters()
            params["deviceToken"] = deviceToken ?? ""
            return params
        }
    }
    var headers: HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .putMy:
            headers["Content-Type"] = "application/json"
        case .putMyImage:
            headers["Content-Type"] = "multipart/form-data"
        default:
            break
        }
        return headers
    }
    func asURLRequest() throws -> URLRequest {
        guard var url = Self.baseURL?.appendingPathComponent(endPoint) else {
            return URLRequest(url: URL(string: "www.naver.com")!)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = self.method
        urlRequest.headers = self.headers
        switch self{
        case .signOut,.getMy,.getUser,.putMyImage: break
        default:
            urlRequest.httpBody = try? JSONEncoding.default.encode(urlRequest, with: parameters).httpBody
        }
        return urlRequest
    }
    var multipartFormData: MultipartFormData {
        let multipartFormData = MultipartFormData()
        switch self {
        case .putMyImage(image: let data):
            if let data{
                multipartFormData.append(data, withName: "image", fileName: "123.jpg", mimeType: "image/jpeg")
            }
        default: ()
        }
        return multipartFormData
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
        if !nick.isEmpty{
            parameters["nickname"] = nick
        }
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
        if !nickName.isEmpty{
            params["nickname"] = nickName
        }
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
