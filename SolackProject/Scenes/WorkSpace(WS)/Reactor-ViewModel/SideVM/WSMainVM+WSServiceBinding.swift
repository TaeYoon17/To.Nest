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
        provider.wsService.event.bind(with: self) { owner, event in
            switch event{
            case .create(let res):
                Task{ await owner.createResponse(res) }
                owner.toastType = .created
            case .edit(let res):
                Task{
                    await owner.editResponse(res)
                    try await Task.sleep(for: .seconds(0.5))
                    await MainActor.run { owner.toastType = .edit}
                }
            case .checkAll(let value):
                owner.wsResponses(value)
            case .delete:
                self.list.remove(at:owner.selectedIdx)
                Task{@MainActor in
                    if let firstItem = owner.list.first{
                        owner.selectedIdx = 0
                        owner.list[owner.selectedIdx].isSelected = true
                        owner.mainWS = owner.list[owner.selectedIdx].id
                        owner.provider.wsService.setHomeWS(wsID:owner.mainWS)
                    }else{
                        self.mainWS = -1
                        owner.selectedIdx = -1
                        owner.provider.wsService.setHomeWS(wsID: nil)
                    }
                }
                Task{
                    try await Task.sleep(for: .seconds(0.5))
                    await MainActor.run { owner.toastType = .edit}
                }
            case .failed(let faild):
                switch faild{
                case .nonExistData:
                    owner.toastType = .emptyData
                case .nonAuthority:
                    owner.toastType = .notAuthority
                case .lackCoin:
                    owner.toastType = .lackCoin
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
extension WSMainVM{
    fileprivate func createResponse(_ value: WSResponse) async {
        let isFirstItem = await self.list.isEmpty
        do{
            var tempItem = try await makeWSItem(value)
            if isFirstItem{ 
                tempItem.isSelected = true
                self.mainWS = tempItem.id
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
    fileprivate func editResponse(_ value:WSResponse) async{
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
    fileprivate func wsResponses(_ value:[WSResponse]){
        Task{
            do{
                let listItem = try await counter.run(value) {[weak self] response in
                    // 여기에 이미지 가져오는 로직 추가해야함
//                    let imageData = try! examineImage.randomElement()!.imageData()
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
    func makeWSItem(_ res:WSResponse,coverCache:Bool = false) async throws -> WorkSpaceListItem{
        let myImage:UIImage
        do{
            myImage = try await UIImage.fetchWebCache(name: res.thumbnail,type:.small)
        }catch{
            let image = if let data = await NM.shared.getThumbnail(res.thumbnail){
                UIImage.fetchBy(data: data,type:.small)
            }else{examineImage.randomElement()!}
            try await image.appendWebCache(name: res.thumbnail,isCover: coverCache)
            myImage = try image.downSample(type:.small)
        }
        return await WorkSpaceListItem(id:res.workspaceID,
                                       isSelected: res.workspaceID == mainWS,
                                       isMyManaging: res.ownerID == userID,
                                       image: myImage,
                                       name: res.name,
                                       description: res.description,
                                       date: res.createdAt)
    }
}
extension WSMainVM{
    func tempToastUp(){
        toastType = .created
    }
}
//MARK: -- 워크스페이스 리스트 아이템
struct WorkSpaceListItem:Identifiable,Equatable{
    var id:Int
    var isSelected:Bool
    var isMyManaging:Bool = false
    var image:UIImage
    var name:String
    var description:String?
    var date:String // 이거 수정해야함!!
}
