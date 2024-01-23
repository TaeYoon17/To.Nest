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
    var signService: SignServiceProtocol { get }
    var wsService: WorkSpaceProtocol { get }
    var chService: ChannelProtocol { get }
}
final class ServiceProvider: ServiceProviderProtocol{
    lazy var authService: AuthServiceProtocol = AuthService()
    lazy var signService: SignServiceProtocol = SignService()
    lazy var wsService: WorkSpaceProtocol = WSService()
    lazy var chService: ChannelProtocol = CHService()
}

