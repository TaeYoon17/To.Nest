//
//  DMRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import Alamofire

enum DMRouter:URLRequestConvertible{
    case check(wsID:Int)
    case create(wsID:Int,roomID:Int,dmInfo:ChatInfo)
    static private let baseURL = URL(string: API.baseURL)
    var endPoint:String{
        switch self{
        case .check(wsID: let wsID):"/v1/workspaces/\(wsID)/dms"
        case .create(wsID: let wsID,roomID: let roomID,_):
            "/v1/workspaces/\(wsID)/dms/\(roomID)/chats"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .check: .get
        case .create: .post
        }
    }
    var params: Parameters{
        var params = Parameters()
        switch self{
        default: break
        }
        return params
    }
    var headers: HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .check: headers["Content-Type"] = "application/json"
        case .create: headers["Content-Type"] = "multipart/form-data"
        }
        return headers
    }
    func asURLRequest() throws -> URLRequest {
        guard var url = Self.baseURL?.appendingPathComponent(endPoint) else {
            return URLRequest(url: URL(string:"www.naver.com")!)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = self.method
        urlRequest.headers = self.headers
        return urlRequest
    }
    var multipartFormData: MultipartFormData {
        let multipartFormData = MultipartFormData()
        switch self {
        case .create(wsID: _, roomID: _,dmInfo: let info):
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
