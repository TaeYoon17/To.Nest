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
extension SideVM{
    func binding(){
        provider.wsService.event.bind(with: self) { owner, event in
            switch event{
            case .create(let res):
                Task{ await owner.createResponse(res) }
//                owner.toastLogicMaker(type: .created)
                owner.toastType = .created
            case .edit(let res):
                Task{ 
                    await owner.editResponse(res)
                    try await Task.sleep(for: .seconds(0.5))
                    await MainActor.run { owner.toastType = .edit}
                }
            case .checkAll(let value):
                // 바꿔주는 로직이 필요하다.
                owner.wsResponses(value)
            case .delete:
                Task{
                    try await Task.sleep(for: .seconds(0.5))
                    await MainActor.run { owner.toastType = .edit}
                }
            case .failed(let faild):
                switch faild{
                case .nonExistData:
                    owner.toastType = .emptyData
                case .nonAuthority:
//                    owner.toastLogicMaker(type: .notAuthority)
                    owner.toastType = .notAuthority
                case .lackCoin:
//                    owner.toastLogicMaker(type: .lackCoin)
                    owner.toastType = .lackCoin
                default:
//                    owner.toastLogicMaker(type: .unknown)
                    owner.toastType = .unknown
                }
            case .unknownError:
                owner.toastType = .unknown
            default: break
            }
        }.disposed(by: disposeBag)
    }
}
extension SideVM{
    fileprivate func createResponse(_ value: WSResponse) async {
        let isFirstItem = await self.list.isEmpty
        do{
            var tempItem = try await makeWSItem(value)
            if isFirstItem{ tempItem.isSelected = true }
            let item = tempItem
            await MainActor.run {
                if isFirstItem{
                    selectedIdx = 0
                    selectedWorkSpaceID = item.id
                }
                list.append(item)
                underList.append(value)
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
                self.underList[self.selectedIdx] = value
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
                Task{@MainActor in
                    self.list = listItem
                    self.underList = value
                    if !self.list.isEmpty{
                        if self.selectedIdx >= 0 { self.list[selectedIdx].isSelected = false }
                        self.list[0].isSelected = true
                        self.selectedWorkSpaceID  = self.list[0].id
                        self.selectedIdx = 0
                    }else{
                        self.selectedIdx = -1
                    }
                }
            }catch{
                print(error)
            }
        }
    }
    func makeWSItem(_ res:WSResponse,coverCache:Bool = false) async throws -> WorkSpaceListItem{
        let myImage:UIImage
        do{
            myImage = try await UIImage.fetchWebCache(name: res.thumbnail,size:.init(width: 44, height: 44))
        }catch{
            let image = examineImage.randomElement()!
            try await image.appendWebCache(name: res.thumbnail,isCover: coverCache)
            myImage = try image.downSample(size: .init(width: 44, height: 44))
        }
        return await WorkSpaceListItem(id:res.workspaceID,
                                       isSelected: list.isEmpty,
                                       isMyManaging:res.ownerID == userID,
                                       image: myImage,
                                       name: res.name,
                                       date: res.createdAt)
    }
}
extension SideVM{
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
    var date:String // 이거 수정해야함!!
}
