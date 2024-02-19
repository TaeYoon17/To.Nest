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
    var msgService: MessageProtocol { get }
    var profileService: ProfileProtocol { get }
    var dmService: DMProtocol{get}
    var payService:PayProtocol { get }
}
final class ServiceProvider: ServiceProviderProtocol{
    lazy var authService: AuthServiceProtocol = AuthService()
    lazy var signService: SignServiceProtocol = SignService()
    lazy var profileService: ProfileProtocol = ProfileService()
    lazy var wsService: WorkSpaceProtocol = WSService()
    lazy var chService: ChannelProtocol = CHService()
    lazy var dmService: DMProtocol = DMService()
    lazy var payService:PayProtocol = PayService()
    var msgService: MessageProtocol = MSGService()
    
}

