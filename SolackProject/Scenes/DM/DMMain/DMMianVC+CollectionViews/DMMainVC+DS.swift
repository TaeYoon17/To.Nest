//
//  DMMainVC+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import UIKit
import SnapKit
import RxSwift
extension DMMainVC{
    final class DataSource:UICollectionViewDiffableDataSource<SectionType,Item>{
        @DefaultsState(\.userID) var userID
        var roomModel = AnyModelStore<DMRoomItem>([])
        var memberModel = AnyModelStore<DMMemberItem>([])
        var dmAssets = NSCache<NSString,DMAssets>() // 유저 아이디로 썸네일 가져옴
        var disposeBag = DisposeBag()
        init(reactor: DMMainReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<DMMainVC.SectionType, DMMainVC.Item>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initDataSource(memberItem: [])
            reactor.state.map{$0.membsers}.bind { [weak self] responses in
                guard let self else {return}
                Task{
                    var items:[Item] = []
                    for response in responses{
                        if response.userID == self.userID { continue }
                        let memberItem = DMMemberItem(userResponse: response)
                        await self.appendDMAsset(memberItem: memberItem)
                        self.memberModel.insertModel(item: memberItem)
                        items.append(Item(memberItem: memberItem))
                    }
                    self.setDataSource(memberItem: items)
                }
            }.disposed(by: disposeBag)
            reactor.state.map{$0.rooms}.throttle(.microseconds(100), scheduler: MainScheduler.asyncInstance).bind { [weak self] responses in
                Task{
                    var items:[Item] = []
                    for response in responses{
                        if response.user.userID == self?.userID {
                            continue
                        }
                        let dmItem = DMRoomItem(roomResponse: response)
                        await self?.appendDMAsset(roomItem: dmItem)
                        self?.roomModel.insertModel(item: dmItem)
                        items.append(Item(roomItem: dmItem))
                    }
                    self?.setDataSource(roomItem: items)
                }
            }.disposed(by: disposeBag)
            reactor.state.map{$0.roomUnreads}.bind { [weak self] responses in
                guard let self,!responses.isEmpty else {return}
                Task{
                    var items:[Item] = []
                    for response in responses{
                        guard var roomItem = self.roomModel.fetchByID(DMRoomItem.idConverter(roomID: response.roomID)) else {continue}
                        roomItem.unreads = response.count
                        self.roomModel.insertModel(item: roomItem)
                        items.append(Item(roomItem: roomItem))
                    }
                    await MainActor.run {
                        var snapshot = self.snapshot()
                        snapshot.reloadItems(items)
                        self.apply(snapshot,animatingDifferences: false)
                    }
                }
            }.disposed(by: disposeBag)
        }
        @MainActor func setDataSource(memberItem:[Item]){
            var snapshot = snapshot()
            let items = snapshot.itemIdentifiers(inSection: .member)
            snapshot.deleteItems(items)
            snapshot.appendItems(memberItem,toSection: .member)
//            Task{@MainActor in
                apply(snapshot,animatingDifferences: true)
//            }
        }
        @MainActor func setDataSource(roomItem:[Item]){
            var snapshot = snapshot()
            let items = snapshot.itemIdentifiers(inSection: .dm)
            snapshot.deleteItems(items)
            snapshot.appendItems(roomItem,toSection: .dm)
            Task{@MainActor in
                apply(snapshot,animatingDifferences: true)
            }
        }
        @MainActor func initDataSource(memberItem: [Item]){
            var snapshot = snapshot()
            snapshot.appendSections([.member,.dm])
            snapshot.appendItems([],toSection: .member)
            snapshot.appendItems([],toSection: .dm)
            apply(snapshot,animatingDifferences: true)
        }
        @discardableResult
        func appendDMAsset(memberItem:MemberListItem) async -> DMAssets{
            let image = if let imageName = memberItem.userResponse.profileImage,
                let imageData = await NM.shared.getThumbnail(imageName){
                UIImage.fetchBy(data: imageData, type: .small)
            }else{ UIImage.noPhotoA}
            let asset = DMAssets(userId: "\(memberItem.userResponse.userID)", image: image)
            self.dmAssets.setObject(asset, forKey: asset.id as NSString)
            return asset
        }
        @discardableResult
        func appendDMAsset(roomItem: DMRoomItem) async -> DMAssets{
            let image = if let imageName = roomItem.profileImage,
                let imageData = await NM.shared.getThumbnail(imageName){
                UIImage.fetchBy(data: imageData, type: .small)
            }else{ UIImage.noPhotoA}
            let asset = DMAssets(userId: "\(roomItem.userID)", image: image)
            self.dmAssets.setObject(asset, forKey: asset.id as NSString)
            return asset
        }
    }
}
