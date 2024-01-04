//
//  NetworkManager.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
import Alamofire
typealias NM = NetworkManager
final class NetworkManager{
    static let shared = NetworkManager()
    let baseInterceptor = BaseInterceptor()
}

