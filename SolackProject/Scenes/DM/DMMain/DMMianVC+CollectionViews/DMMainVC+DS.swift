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
        var memberModel = AnyModelStore<DMMemberItem>([])
        var memberAssets = NSCache<NSString,MemberListAsset>()
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
                        await self.appendMemberAsset(memberItem: memberItem)
                        self.memberModel.insertModel(item: memberItem)
                        items.append(Item(memberItem: memberItem))
                    }
                    self.setDataSource(memberItem: items)
                }
            }.disposed(by: disposeBag)
        }
        @MainActor func setDataSource(memberItem:[Item]){
            var snapshot = snapshot()
            let items = snapshot.itemIdentifiers(inSection: .member)
            snapshot.deleteItems(items)
            snapshot.appendItems(memberItem,toSection: .member)
            Task{@MainActor in
                await apply(snapshot,animatingDifferences: true)
            }
        }
        @MainActor func initDataSource(memberItem: [Item]){
            var snapshot = snapshot()
            snapshot.appendSections([.member,.dm])
            let dmItem = [Item(dmItem: .init(dmID: 1,sectionType: .dm)),Item(dmItem: .init(dmID: 2,sectionType: .dm))]
            snapshot.appendItems([],toSection: .member)
            snapshot.appendItems(dmItem,toSection: .dm)
            apply(snapshot,animatingDifferences: true)
        }
        @discardableResult
        func appendMemberAsset(memberItem:MemberListItem) async -> MemberListAsset{
            let image = if let imageName = memberItem.userResponse.profileImage,
                let imageData = await NM.shared.getThumbnail(imageName){
                UIImage.fetchBy(data: imageData, type: .small)
            }else{ UIImage.noPhotoA}
            let asset = MemberListAsset(userId: memberItem.id, image: image)
            self.memberAssets.setObject(asset, forKey: asset.id as NSString)
            return asset
        }
    }
}
