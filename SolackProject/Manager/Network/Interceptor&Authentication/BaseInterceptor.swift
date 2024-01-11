//
//  BaseInterceptor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
final class BaseInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue(API.key, forHTTPHeaderField: "SesacKey")
        completion(.success(request))
    }
}
