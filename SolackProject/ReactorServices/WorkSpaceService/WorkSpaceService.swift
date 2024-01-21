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
    func create(_ info:WSInfo)
    func edit(_ info:WSInfo,id:String)
    func delete(workspaceID: String)
    func checkAllWS(isCover:Bool)
    func initHome()
    func setHomeWS(wsID:Int)
}
final class WorkSpaceService:WorkSpaceProtocol{
    @DefaultsState(\.mainWS) var mainWS
    private var prevResponse:[WSResponse]? = nil
    let event = PublishSubject<Event>()
    enum Event{
        case homeWS(WSDetailResponse?)
        case create(WSResponse)
        case edit(WSResponse)
        case checkAll([WSResponse])
        case delete
        case failed(WSFailed)
        case unknownError
        case requireReSign
    }
    func create(_ info:WSInfo){
        Task{
            do{
                let res = try await NM.shared.createWS(info)
                event.onNext(.create(res))
            }catch{
                print("create Error 가져오기 성공")
                guard authValidCheck(error: error) else{
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                print("걸리기 실패 \(error)")
                if let failed = error as? WSFailed{
                    event.onNext(.failed(failed))
                    return
                }
                event.onNext(.unknownError)
            }
        }
    }
    func edit(_ info:WSInfo,id:String){
        Task{
            do{
                let res = try await NM.shared.editWS(info,wsID: id)
                event.onNext(.edit(res)) // 이 일은 SideVM에서 처리하겠지..?
            }catch{
                print("edit Error 가져오기 성공")
                guard authValidCheck(error: error) else{
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                print("걸리기 실패 \(error)")
                if let failed = error as? WSFailed{
                    event.onNext(.failed(failed))
                    return
                }
                event.onNext(.unknownError)
            }
        }
    }
    
    func checkAllWS(isCover: Bool = false){
        if let prevResponse, isCover == false{
            event.onNext(.checkAll(prevResponse))
            return
        }
        Task{
            do{
                let allWS = try await NM.shared.checkAllWS()
                event.onNext(.checkAll(allWS))
            }catch{
                print("워크스페이스 사이드 에러!!")
                guard authValidCheck(error: error) else{
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                print("걸리기 실패",error)
            }
        }
    }
    func delete(workspaceID: String){
        Task{
            do{
                try await NM.shared.deleteWS(workspaceID)
                checkAllWS()
            }catch{
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let ws = error as? WSFailed{
                    return
                }
                // 그냥 알 수 없는 에러라고 보내버리기
                event.onNext(.unknownError)
            }
        }
    }
    
}
