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
    }
}
enum WorkSpaceRouter:URLRequestConvertible{
    case create(info:WSInfo),check(CheckType),edit(wsID:String,info:WSInfo),delete(wsID: String),invite,search,leave,adminChange
    static private let baseURL = URL(string: API.baseURL + "/v1/workspaces")
    var endPoint:String{
        switch self{
        case .adminChange: ""
        case .check(let checkType):
            switch checkType{
            case .my(id: let myID): "/\(myID)"
            default:""
            }
        case .create: ""
        case .delete(let wsID): "/\(wsID)"
        case .invite: ""
        case .edit(let id,_): "/\(id)"
        case .search: ""
        case .leave: ""
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
        switch self{
        case .adminChange: .init()
        case .create: .init()
        case .check(_): .init()
        case .edit: .init()
        case .delete: .init()
        case .invite: .init()
        case .search: .init()
        case .leave: .init()
        }
    }
    var headers:HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .create,.edit:
            headers["Content-Type"] = "multipart/form-data"
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
                print("이미지 존재함!!")
                multipartFormData.append(image, withName: "image", fileName: "\(info.name ?? "")123.jpg", mimeType: "image/jpeg")
            }
            multipartFormData.append(Data(info.name.utf8), withName: "name")
            multipartFormData.append(Data(info.description.utf8), withName: "description")
        default: ()
        }
        return multipartFormData
    }
}
