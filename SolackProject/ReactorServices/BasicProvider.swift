//
//  BasicProvider.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import Foundation
import RxSwift
protocol ServiceProviderProtocol: AnyObject{
    var authService: AuthServiceProtocol { get }
    var signUpService: SignUpServiceProtocol { get }
    var signInService: SignInServiceProtocol {get}
}
final class ServiceProvider: ServiceProviderProtocol{
    lazy var authService: AuthServiceProtocol = AuthService()
    lazy var signUpService: SignUpServiceProtocol = SignUpService()
    lazy var signInService: SignInServiceProtocol = SignInService()
}

