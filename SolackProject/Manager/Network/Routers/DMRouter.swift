//
//  DMRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import Foundation
import Alamofire

enum DMRouter:URLRequestConvertible{
    case checkRoom(wsID:Int)
    case create(wsID:Int,roomID:Int,dmInfo:ChatInfo)
    case check(wsID:Int,userID:Int,date:Date?)
    case unread(wsID:Int,roomID:Int,date:Date?)
    static private let baseURL = URL(string: API.baseURL)
    var endPoint:String{
        switch self{
        case .checkRoom(wsID: let wsID):"/v1/workspaces/\(wsID)/dms"
        case .create(wsID: let wsID,roomID: let roomID,_):
            "/v1/workspaces/\(wsID)/dms/\(roomID)/chats"
        case .check(let wsID,let userID,_): "/v1/workspaces/\(wsID)/dms/\(userID)/chats"
        case .unread(wsID: let wsID, roomID: let roomID, date: _):
            "/v1/workspaces/\(wsID)/dms/\(roomID)/unreads"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .checkRoom,.check,.unread: .get
        case .create: .post
        }
    }
    var params: Parameters{
        var params = Parameters()
        switch self{
        case .check(wsID: _, userID: _, date: let date):
            if let date{
                params["cursor_date"] = date.ISO8601Format()
            }
        case .unread(wsID: _, roomID: _, date: let date):
            if let date{
                params["after"] = date.ISO8601Format()
            }
        default: break
        }
        return params
    }
    var headers: HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .checkRoom: headers["Content-Type"] = "application/json"
        case .create: headers["Content-Type"] = "multipart/form-data"
        case .check,.unread: headers["accept"] = "application/json"
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
        switch self{
        case .check,.unread:
            if let queryItems = self.params.urlQueryItems{
                urlRequest.url?.append(queryItems: queryItems)
            }
        default: break
        }
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
