//
//  WorkSpaceRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import Alamofire
typealias WSRouter = WorkSpaceRouter
extension WorkSpaceRouter{
    enum CheckType{
        case my(id:String)
        case myAll
        case member(id:String,userID:String?)
        case memberAll(id: Int)
    }
}
enum WorkSpaceRouter:URLRequestConvertible{
    case create(info:WSInfo),check(CheckType),edit(wsID:String,info:WSInfo),delete(wsID: Int)
    case invite(wsID:Int,email:String),search,leave(wsID:Int),adminChange
    static private let baseURL = URL(string: API.baseURL + "/v1/workspaces")
    var endPoint:String{
        switch self{
        case .adminChange: ""
        case .check(let checkType):
            switch checkType{
            case .my(id: let myID): "/\(myID)"
            case .memberAll(id: let wsID): "/\(wsID)/members"
            default:""
            }
        case .create: ""
        case .delete(let wsID): "/\(wsID)"
        case .invite(let wsID,_): "/\(wsID)/members"
        case .edit(let id,_): "/\(id)"
        case .search: ""
        case .leave(let id): "/\(id)/leave"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .create,.invite: .post
        case .check,.search,.leave: .get
        case .edit,.adminChange: .put
        case .delete: .delete
        }
    }
    var params: Parameters{
        var params = Parameters()
        switch self{
        case .adminChange: break
        case .create: break
        case .check(_): break
        case .edit: break
        case .delete: break
        case .invite(_ ,let email): params["email"] = email
        case .search: break
        case .leave: break
        }
        return params
    }
    var headers:HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .create,.edit:
            headers["Content-Type"] = "multipart/form-data"
        case .invite:
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
        switch self{
        case .create,.edit:
            return urlRequest
        default: break
        }
        switch self.method{
        case .get: break
        default: urlRequest.httpBody = try? JSONEncoding.default.encode(urlRequest, with: params).httpBody
        }
        return urlRequest
    }
    var multipartFormData: MultipartFormData {
        let multipartFormData = MultipartFormData()
        switch self {
        case .create(let info),.edit(wsID: _, info: let info):
            if let image = info.image{
                multipartFormData.append(image, withName: "image", fileName: "\(info.name ?? "")123.jpg", mimeType: "image/jpeg")
            }
            multipartFormData.append(Data(info.name.utf8), withName: "name")
            multipartFormData.append(Data(info.description.utf8), withName: "description")
        default: ()
        }
        return multipartFormData
    }
}
