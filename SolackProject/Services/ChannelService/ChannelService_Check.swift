//
//  ChannelService_Check.swift
//  SolackProject
//
//  Created by 김태윤 on 2/12/24.
//

import Foundation
import RxSwift
import RealmSwift
extension ChannelService{
    func check(title:String){
        Task{
            do{
                let response = try await NM.shared.checkCH(wsID: mainWS.id,channelName: title)
                event.onNext(.check(response))
                let users = try await NM.shared.checkCHUsers(wsID: mainWS.id, channelName: title)
                let channelID = response.channelID
                event.onNext(.channelUsers(id: channelID, users))
            }catch{
                print(error)
            }
        }
    }
    func checkUser(channelID:Int,title:String){
        Task{
            do{
                let users = try await NM.shared.checkCHUsers(wsID: mainWS.id, channelName: title)
                event.onNext(.channelUsers(id: channelID, users))
            }catch{
                print(error)
            }
        }
    }
    func checkAll(){
        Task{
            do{
                let results:[CHResponse] = try await NM.shared.checkAllCH(wsID: mainWS.id)
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
        Task{ await _checkAllMy() }
    }
    func _checkAllMy() async {
        do{
            print("checkAllMy mainWS \(mainWS)")
            let results = try await NM.shared.checkAllMyCH(wsID: mainWS.id)
            self.event.onNext(.allMy(results))
            // 해당 워크스페이스 아이디를 갖으면서
            // 기존에 없었던 테이블 생성... or 기존에 있었지만 받아온 채널아이디가 없는 테이블 삭제
            Task{@BackgroundActor in
                for v in results{ // 채널 response
                    try await Task.sleep(for: .microseconds(10))
                    if let table = repository.getTableBy(tableID: v.channelID){
                        // 기존에 존재하는 채널... 업데이트 필요
                        await repository.updateChannelName(channelID: v.channelID, name: v.name)
                    }else{// 기존에 존재하지 않아서 새로 추가해야하는 채널
                        await repository.create(item: ChannelTable(channelInfo: v))
                    }
                }
                let exiseted = repository.getTasks.where { $0.wsID == self.mainWS.id}
                let checkUnreads = Array(exiseted.map{ ($0.lastReadDate,$0.channelName) })
                let existedChannels = exiseted.map{$0.channelID}
                let removeChannelIDs = Set(existedChannels).subtracting(results.map{$0.channelID})
                Task.detached {
                    var unreadsResponses: [UnreadsChannelRes] = []
                    for checks in checkUnreads{
                        do{
                            let unreads = try await self.updateChannelUnreads(channelName: checks.1,lastDate: checks.0)
                            unreadsResponses.append(unreads)
                        }catch{
                            print(error)
                            print("여기 에러")
                        }
                    }
                    let responses = unreadsResponses
                    await MainActor.run {
                        self.event.onNext(.unreads(responses))
                    }
                }
                repository.removeChannelTables(ids: Array(removeChannelIDs))
            }
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
