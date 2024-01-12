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
    func delete(workspaceID: String)
    func checkAllWS()
}
final class WorkSpaceService:WorkSpaceProtocol{
    let event = PublishSubject<Event>()
    enum Event{
        case create(WSResponse)
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
                print("걸리기 실패")
                event.onNext(.unknownError)
            }
        }
    }
    func checkAllWS(){
        Task{
            do{
                let allWS = try await NM.shared.checkAllWS()
                event.onNext(.checkAll(allWS))
                print(allWS)
//                var list = try await counter.run(allWS) { wsResponse in     
//                    wsResponse.thumbnail
//                    return WorkSpaceListItem(isSelected: false, imageName: <#T##String#>, name: wsResponse.name, date: wsResponse.createdAt ?? "")
//                }
//                if list.count > 0{
//                    list[0].isSelected = true
//                }
//                self.list = list
//                self.underList = allWS
            }catch{
                print("워크스페이스 사이드 에러!!")
                guard authValidCheck(error: error) else{
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                print("걸리기 실패")
            }
        }
    }
    func delete(workspaceID: String){
        Task{
            do{
                try await NM.shared.deleteWS(workspaceID)
            }catch{
                guard authValidCheck(error: error) else {
                    print("재로그인 필요!!")
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
