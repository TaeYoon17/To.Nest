//
//  PayRouter.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import Foundation
import Alamofire

enum PayRouter:URLRequestConvertible{
    case validation(imp:String,merchant:String), itemList
    static let baseURL = URL(string: API.baseURL + "/v1/store")
    var endPoint:String{
        switch self{
        case .itemList: "/item/list"
        case .validation: "/pay/validation"
        }
    }
    var method:HTTPMethod{
        switch self{
        case .itemList: .get
        case .validation: .post
        }
    }
    var header: HTTPHeaders{
        var header = HTTPHeaders()
        switch self{
        case .validation:
            header["Content-Type"] = "application/json"
        default:break
        }
        return header
    }
    var params: Parameters{
        var param = Parameters()
        switch self{
        case .validation(let imp, let merchant):
            param["imp_uid"] = imp
            param["merchant_uid"] = merchant
        case .itemList: break
        }
        return param
    }
    func asURLRequest() throws -> URLRequest {
        guard let url = Self.baseURL?.appendingPathComponent(endPoint) else {
            return URLRequest(url: URL(string: "www.naver.com")!)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.method = self.method
        urlRequest.headers = self.header
        switch self{
        case .validation:
            urlRequest.httpBody = try? JSONEncoding.default.encode(urlRequest, with: params).httpBody
        default: break
        }
        return urlRequest
    }
}
