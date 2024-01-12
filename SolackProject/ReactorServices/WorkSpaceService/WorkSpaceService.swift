//
//  WorkSpaceService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import RxSwift
typealias WSService = WorkSpaceService
protocol WorkSpaceProtocol{
    var event: PublishSubject<WorkSpaceService.Event> {get}
    func requestCreate(_ info:WSInfo)
}
final class WorkSpaceService:WorkSpaceProtocol{
    let event = PublishSubject<Event>()
    enum Event{
        case create(WSResponse)
        case failed(WSFailed)
        case unknownError
        case requireReSign
    }
    func requestCreate(_ info:WSInfo){
        Task{
            do{
                let res = try await NetworkManager.shared.createWS(info)
                event.onNext(.create(res))
            }catch let failed where failed is WSFailed{ // 내 문제
                event.onNext(.failed(failed as! WSFailed))
                print(failed as! WSFailed)
            }catch let failed where failed is AuthFailed{
                switch failed as! AuthFailed{
                    case .authFailed: print("재 로그인 필요")
                    case .expiredRefresh: print("재 로그인 필요")
                    case .isValid: print("재 로그인 필요")
                    case .unknownAccount: print("재 로그인 필요")
                }
//                event.onNext(.unknownError)
                event.onNext(.requireReSign)
            }catch{
                print(error)
                event.onNext(.unknownError)
            }
        }
        
    }
}
