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
    @DefaultsState(\.accessToken) var accessToken
    @DefaultsState(\.refreshToken) var refreshToken
    static let accessExpireSeconds:Double = 60
    static let shared = NetworkManager()
    let baseInterceptor = BaseInterceptor()
    var authInterceptor = AuthenticatorInterceptor()
}

