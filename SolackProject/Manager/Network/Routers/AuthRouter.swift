//
//  AuthRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import Alamofire

enum AuthRouter:URLRequestConvertible{
    case refresh(refreshToken:String,accessToken:String)
    static let baseURL = URL(string: API.baseURL + "/v1/auth")
    var endPoint:String{
        switch self{
        case .refresh: "/refresh"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .refresh: .get
        }
    }
    var header: HTTPHeaders{
        var header = HTTPHeaders()
        switch self{
        case .refresh(let refresh,let access):
            header["Authorization"] = access
            header["RefreshToken"] = refresh
        }
        return header
    }
    func asURLRequest() throws -> URLRequest {
        guard let url = Self.baseURL?.appendingPathComponent(endPoint) else {
            return URLRequest(url: URL(string: "www.naver.com")!)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = self.method
        urlRequest.headers = self.header
        return urlRequest
    }
}
