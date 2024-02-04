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
    static private let baseURL = URL(string: API.baseURL)
    var endPoint:String{
        switch self{
        case .check(wsID: let wsID):"v1/workspaces/\(wsID)/dms"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .check: .get
        }
    }
    var params: Parameters{
        var params = Parameters()
        return params
    }
    var headers: HTTPHeaders{
        var headers = HTTPHeaders()
        switch self{
        case .check: headers["Content-Type"] = "application/json"
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
}
