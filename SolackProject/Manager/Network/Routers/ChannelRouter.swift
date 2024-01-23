//
//  ChannelRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/23/24.
//

import Foundation
import Alamofire
typealias CHRouter = ChannelRouter
extension CHRouter{
    enum CheckType{
        case all
        case allMy
        case my(chName:String)
        case members(chName:String)
    }
}
enum ChannelRouter:URLRequestConvertible{
    case create(wsID: Int,info:CHInfo)
    case check(wsID:Int,CheckType),leave(wsID: Int,chName: String),unreads(wsID:Int,chName:String)
    case edit(wsID: Int,chName:String,info:CHInfo),changeAdmin(wsID:Int,chName:String,userID:String)
    case delete(wsID: Int,chName: String)
    static private let baseURL = URL(string: API.baseURL + "/v1/workspaces")
    var endPoint:String{
        switch self{
        case .create(let wsID,_): "/\(wsID)/channels"
        case .check(wsID: let wsID, let type):
            switch type{
            case .allMy: "/\(wsID)/channels/my"
            case .my(let name),.members(let name): "/\(wsID)/channels/my/\(name)"
            case .all: "/\(wsID)/channels/my"
            }
        case .unreads(wsID: let wsID, chName: let chName): "/\(wsID)/channels/\(chName)/chats"
        case .edit(wsID: let wsID, chName: let name,_),.delete(wsID: let wsID, chName: let name): "/\(wsID)/channels/\(name)"
        case .leave(wsID: let wsID, chName: let chName): "/\(wsID)/channels/\(chName)/leave"
        case .changeAdmin(wsID: let wsID, chName: let chName, userID: let userID): "/\(wsID)/channels/\(chName)/change/admin/\(userID)"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .create: .post
        case .check,.leave,.unreads: .get
        case .edit,.changeAdmin: .put
        case .delete: .delete
        }
    }
    var params: Parameters{
        var parameters = Parameters()
        switch self{
        case .create(_,let info):
            parameters["name"] = info.name
            parameters["description"] = info.description
        default: break
        }
        return parameters
    }
    var headers:HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .create:
            headers["Content-Type"] = "application/json"
        default: break
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
        switch self.method{
        case .get: break
        default: urlRequest.httpBody = try? JSONEncoding.default.encode(urlRequest, with: params).httpBody
        }
        return urlRequest
    }
    var multipartFormData: MultipartFormData {
        let multipartFormData = MultipartFormData()
        return multipartFormData
    }
}
