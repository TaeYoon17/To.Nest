//
//  SideVM+WSServiceBinding.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import Combine
import RxSwift
import UIKit
extension WSMainVM{
    func binding(){
        provider.wsService.event.bind(with: self) {[weak self] owner, event in
            guard let self else {return}
            switch event{
            case .create(let res):// 1. 생성하기 결과
                Task{ await owner.createResponse(res) }
                owner.toastType = .created
            case .edit(let res): // 2. 수정하기 결과
                Task{
                    await owner.editResponse(res)
                    try await Task.sleep(for: .seconds(0.5))
                    await MainActor.run { owner.toastType = .edit}
                }
            case .checkAll(let value): // 3. 워크스페이스 전체 조회
                owner.wsResponses(value)
            case .delete: // 4. 삭제했다.
                removeWorkSpaceList()
                Task{
                    try await Task.sleep(for: .seconds(0.5))
                    await MainActor.run { owner.toastType = .delete}
                }
            case .exit: // 5. 나갔다.
                removeWorkSpaceList()
            case .adminChanged(let response):
                self.toastType = .managerChangeSuccess
                self.list[self.selectedIdx].isMyManaging = false
                Task{@MainActor in
                    self.mainWS.updateMainWSID(id:response.workspaceID,myManaging:false)
                    self.toastType = .managerChangeSuccess
                }
            case .failed(let faild): // 다양한 실패들...
                switch faild{
                case .nonExistData:
                    owner.toastType = .emptyData
                case .nonAuthority:
                    owner.toastType = .notAuthority
                case .lackCoin:
                    owner.toastType = .lackCoin
                case .denyExitWS:
                    owner.toastType = .existChannelManaging
                default:
                    owner.toastType = .unknown
                }
            case .unknownError:
                owner.toastType = .unknown
            default: break
            }
        }.disposed(by: disposeBag)
    }
}
fileprivate extension WSMainVM{
     func createResponse(_ value: WSResponse) async {
        let isFirstItem = await self.list.isEmpty
        do{
            var tempItem = try await makeWSItem(value)
            if isFirstItem{
                tempItem.isSelected = true
                await self.mainWS.updateMainWSID(id: tempItem.id, myManaging: true)
            }
            let item = tempItem
            await MainActor.run {
                if isFirstItem{
                    selectedIdx = 0
                    selectedWorkSpaceID = item.id
                }
                list.append(item)
            }
        }catch{
            print(error)
        }
    }
    func editResponse(_ value:WSResponse) async{
        do{
            // 캐시 덮어쓰기
            var tempItem = try await makeWSItem(value,coverCache: true)
            tempItem.isSelected = true
            let item = tempItem
            Task{@MainActor in
                self.list[self.selectedIdx] = item
                self.selectedWorkSpaceID = item.id
            }
        }catch{
            print(error)
        }
    }
    // 워크스페이스 리스트에서 삭제 및 메인 워크스페이스 변경 후, 서비스에서 업데이트 시도
    func removeWorkSpaceList(){
        self.list.remove(at:selectedIdx)
        Task{@MainActor in
            if let firstItem = list.first{
                selectedIdx = 0
                list[selectedIdx].isSelected = true
                mainWS.updateMainWSID(id: list[selectedIdx].id, myManaging: list[selectedIdx].isMyManaging)
                provider.wsService.setHomeWS(wsID:mainWS.id)
            }else{
                self.mainWS.updateMainWSID(id: -1, myManaging: false)
                selectedIdx = -1
                provider.wsService.setHomeWS(wsID: nil)
            }
        }
    }
    func wsResponses(_ value:[WSResponse]){
        Task{
            do{
                let listItem = try await counter.run(value) {[weak self] response in
                    // 여기에 이미지 가져오는 로직 추가해야함
                    guard let self else{ throw Errors.cachingEmpty }
                    return try await makeWSItem(response)
                }
                DispatchQueue.main.async{
                    self.list = listItem
                    self.selectedIdx = self.list.firstIndex(where: {$0.isSelected}) ?? -1
                    self.isReceivedWorkSpaceList = true
                }
            }catch{
                print(error)
            }
        }
    }
}
