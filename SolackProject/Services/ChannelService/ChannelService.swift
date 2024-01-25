//
//  ChannelService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/23/24.
//

import Foundation
import RxSwift
typealias CHService = ChannelService
protocol ChannelProtocol{
    var event:PublishSubject<CHService.Event> {get}
    var transition: PublishSubject<CHService.Transition> { get }
    func create(_ info:CHInfo)
    func checkAllMy()
    func checkAll()
}
final class ChannelService:ChannelProtocol{
    @DefaultsState(\.mainWS) var mainWS
    let event = PublishSubject<Event>()
    let transition = PublishSubject<Transition>()
    enum Event{
        case create(CHResponse)
        case allMy([CHResponse])
        case all([CHResponse])
        case failed(ChannelFailed)
    }
    enum Transition{
        case goChatting
    }
    func create(_ info: CHInfo){
        Task{
            do{
                let result = try await NM.shared.createCH(wsID: mainWS, info)
                event.onNext(.create(result))
            }catch{
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let chError = error as? ChannelFailed{
                    event.onNext(.failed(chError))
                }
            }
        }
    }
    func checkAll(){
        Task{
            do{
                
                let results = try await NM.shared.checkAllCH(wsID: mainWS)
                event.onNext(.all(results))
            }catch{
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let chError = error as? ChannelFailed{
                    event.onNext(.failed(chError))
                }
            }
        }
    }
    func checkAllMy() {
        Task{
            do{
                print("checkAllMy mainWS \(mainWS)")
                let result = try await NM.shared.checkAllMyCH(wsID: mainWS)
                event.onNext(.allMy(result))
            }catch{
                print("checkAllMy() 여기 에러")
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let chError = error as? ChannelFailed{
                    event.onNext(.failed(chError))
                }
            }
        }
    }
    func authValidCheck(error: Error)->Bool{
        print(error)
        if let auth = error as? AuthFailed{
            switch auth{
            case .isValid: return true // 로그인 필요 X
            default: return false // 재로그인 로직 돌리기
            }
        }
        return true
    }
}
