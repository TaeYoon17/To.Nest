//
//  SideVM+WSServiceBinding.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import Foundation
import Combine
import RxSwift
import UIKit
extension SideVM{
    func binding(){
        provider.wsService.event.bind(with: self) { owner, event in
            switch event{
            case .checkAll(let value):
                // 바꿔주는 로직이 필요하다.
                owner.wsResponses(value)
            case .delete: break
            case .failed(let faild):
                switch faild{
                case .nonExistData:
                    owner.toastLogicMaker(type: .emptyData)
                case .nonAuthority:
                    owner.toastLogicMaker(type: .notAuthority)
                default:
                    owner.toastLogicMaker(type: .unknown)
                }
            case .unknownError:
                owner.toastLogicMaker(type: .unknown)
            default: break
            }
        }.disposed(by: disposeBag)
    }
}
extension SideVM{
    
    fileprivate func wsResponses(_ value:[WSResponse]){
        Task{
            do{
                let listItem = try await counter.run(value) {[weak self] response in
                    // 여기에 이미지 가져오는 로직 추가해야함
//                    let imageData = try! examineImage.randomElement()!.imageData()
                    let myImage:UIImage
                    do{
                        myImage = try await UIImage.fetchWebCache(name: response.thumbnail,size:.init(width: 44, height: 44))
                    }catch{
                        let image = examineImage.randomElement()!
                        try await image.appendWebCache(name: response.thumbnail)
                        myImage = try image.downSample(size: .init(width: 44, height: 44))
                    }
                    return WorkSpaceListItem(id:response.workspaceID,
                                             isSelected: false,
                                             isMyManaging:response.ownerID == self?.userID,
                                             image: myImage,
                                             name: response.name,
                                             date: response.createdAt)
                }
                Task{@MainActor in
                    self.list = listItem
                    if !self.list.isEmpty{ self.list[0].isSelected = true }
                    self.selectedWorkSpaceID  = self.list[0].id
                    self.underList = value
                }
            }catch{
                print(error)
            }
        }
    }
}
extension SideVM{
    fileprivate func toastLogicMaker(type: WSToastType){
        let logic: Observable<WSToastType?> = .just(type).delay(.seconds(1), scheduler: MainScheduler.instance)
        let toastLogic =  Observable.concat([ logic, .just(nil) ])
        toastLogic.bind(to: toastPublish).disposed(by: disposeBag)
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
