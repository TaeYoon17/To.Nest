//
//  ImageRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import Alamofire

enum ImageRouter:URLRequestConvertible{
    case get(urlStr: String)
    static private let baseURL = URL(string: API.baseURL + "/v1")
    var endPoint:String{
        switch self{
        case .get(urlStr: let urlStr): urlStr
        }
    }
    var method: HTTPMethod{
        switch self{
        case .get: .get
        }
    }
    func asURLRequest() throws -> URLRequest {
        guard var url = Self.baseURL?.appendingPathComponent(endPoint) else {
            print("hello world")
            return URLRequest(url: URL(string: "www.naver.com")!)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = self.method
        return urlRequest
    }
}
