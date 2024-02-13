//
//  WorkSpaceService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import RxSwift
/// 워크스페이스 서비스에서는 DB 및 도큐먼트에 접근하는 API를 사용하지 않음
/// 예외) 워크스페이스 삭제의 경우, DB 및 도큐먼트에 데이터를 삭제함
typealias WSService = WorkSpaceService
protocol WorkSpaceProtocol{
    var event: PublishSubject<WorkSpaceService.Event> {get}
    func create(_ info:WSInfo)
    func edit(_ info:WSInfo)
    func delete(workspaceID: Int)
    func exit(workspaceID: Int)
    func checkAllWS()
    func initHome()
    func setHomeWS(wsID:Int?) // 홈 워크스페이스 변경
    //MARK: -- 유저(멤버) 관련
    func inviteUser(emailText:String) // 유저 초대
    func checkAllMembers() // 워크스페이스 내부 모든 멤버 조회
    func changeAdmin(userID:Int)
}
final class WorkSpaceService:WorkSpaceProtocol{
    @DefaultsState(\.mainWS) var mainWS
    @DefaultsState(\.userID) var userID
    var channelRepository: ChannelRepository!
    var dmRoomRepository: DMRoomRepository!
    var userRepository: UserInfoRepository!
    @BackgroundActor var imageReferenceCountManager: ImageRCM!
    @BackgroundActor var userReferenceCountManager: UserRCM!
    let event = PublishSubject<Event>()
    enum Event{
        case homeWS(WSDetailResponse?)
        case create(WSResponse)
        case edit(WSResponse)
        case checkAll([WSResponse])
        case delete
        case exit
        case failed(WSFailed)
        case unknownError
        case requireReSign
        case invited(UserResponse)
        case wsAllMembers([UserResponse])
        case adminChanged(WSResponse)
    }
    init(){
        Task{@BackgroundActor in
            channelRepository = try await ChannelRepository()
            dmRoomRepository = try await DMRoomRepository()
            userRepository = try await UserInfoRepository()
            userReferenceCountManager = UserRCM.shared
            imageReferenceCountManager = ImageRCM.shared
        }
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
    func edit(_ info:WSInfo){
        Task{
            do{
                var mainWS = mainWS.id
                let res = try await NM.shared.editWS(info,wsID: mainWS)
                event.onNext(.edit(res)) // 이 일은 SideVM에서 처리하겠지..?
                self.setHomeWS(wsID: res.workspaceID)
            }catch{
                print("edit Error 가져오기  에러")
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
    
    func checkAllWS(){
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
    
    //MARK: -- Delete WorkSpace
    func delete(workspaceID: Int){
        Task{
            do{
                let res = try await NM.shared.deleteWS(workspaceID)
                if res{
                    await self.deleteAllDB(byWSId: workspaceID)
                    event.onNext(.delete)
                }
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
    //MARK: -- Exit Workspace 나가기
    func exit(workspaceID: Int){
        Task{
            do{
                print("workSpaceID \(workspaceID)")
                let res = try await NM.shared.exitWS(workspaceID)
                if res{
                    await self.deleteAllDB(byWSId: workspaceID)
                    event.onNext(.exit)
                }else{
                    event.onNext(.unknownError)
                }
            }catch{
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let ws = error as? WSFailed{
                    event.onNext(.failed(ws))
                    return
                }
                // 그냥 알 수 없는 에러라고 보내버리기
                event.onNext(.unknownError)
            }
        }
    }
}
