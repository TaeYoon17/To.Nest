//
//  ChatRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import Alamofire

enum ChatRouter:URLRequestConvertible{
    case create(wsID: Int,chName:String,info:ChatInfo)
    case check(wsID:Int,chName:String, cursorDate:Date?)
    static private let baseURL = URL(string: API.baseURL + "/v1/workspaces")
    var endPoint:String{
        switch self{
        case .check(wsID: let wsID, chName: let chName, cursorDate: _):
            "/\(wsID)/channels/\(chName)/chats"
        case .create(wsID: let wsID, chName: let chName, info: _):
            "/\(wsID)/channels/\(chName)/chats"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .check: .get
        case .create: .post
        }
    }
    var params: Parameters{
        var parameters = Parameters()
        switch self{
        case .check(wsID: _, chName: _, cursorDate: let date):
            if let date{
                parameters["cursor_date"] = date.convertToString()
            }
        default: break
        }
        return parameters
    }
    var headers:HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .create:
            headers["Content-Type"] = "multipart/form-data"
            headers["accept"] = "application/json"
        case .check:
            headers["Content-Type"] = "application/json"
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
        case .create: return urlRequest
        case .check:
            if let queryItem = params.urlQueryItems{
                urlRequest.url?.append(queryItems: queryItem)
            }
            return urlRequest
        }
    }
    var multipartFormData: MultipartFormData {
        let multipartFormData = MultipartFormData()
        switch self {
        case .create(wsID: let wsID, chName: let chName, info: let info):
            for file in info.files{
                let fileName = "\(file.name).\(file.type.rawValue)"
                print(fileName, fileName,file.type.mimeType)
                multipartFormData.append(file.file, withName: "files",fileName: fileName,mimeType: file.type.mimeType)
            }
            multipartFormData.append(Data(info.content.utf8), withName: "content")
        default: ()
        }
        return multipartFormData
    }
}
