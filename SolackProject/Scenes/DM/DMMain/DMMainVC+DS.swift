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
                        var memberItem = DMMemberItem(userResponse: response)
                        if let imgURL = response.profileImage,let imageData = await NM.shared.getThumbnail(imgURL){
                            let image = UIImage.fetchBy(data: imageData, type: .small)
                            var memberAsset = MemberListAsset(userId: memberItem.id, image: image)
                            self.appendMemberAsset(memberItem: memberItem)
                        }
                        self.memberModel.insertModel(item: memberItem)
                        items.append(Item(memberItem: memberItem))
                    }
                    self.setDataSource(memberItem: items)
                }
            }.disposed(by: disposeBag)
//            let memberItems = [
//                DMMemberItem(userResponse: .init(userID: 1, email: "asd", nickname: "aaa", profileImage: "NoPhotoA")),
//                DMMemberItem(userResponse: .init(userID: 2, email: "asd", nickname: "bbb", profileImage: "NoPhotoA")),
//                DMMemberItem(userResponse: .init(userID: 3, email: "asd", nickname: "ccc", profileImage: "NoPhotoA")),
//                DMMemberItem(userResponse: .init(userID: 4, email: "asd", nickname: "ddd", profileImage: "NoPhotoA")),
//                DMMemberItem(userResponse: .init(userID: 5, email: "asd", nickname: "eee", profileImage: "NoPhotoA")),
//                DMMemberItem(userResponse: .init(userID: 6, email: "asd", nickname: "fff", profileImage: "NoPhotoA")),
//                DMMemberItem(userResponse: .init(userID: 7, email: "asd", nickname: "ggg", profileImage: "NoPhotoA")),
//            ]
//            var items:[Item] = []
//            for memberItem in memberItems {
//                memberModel.insertModel(item: memberItem)
//                self.appendMemberAsset(memberItem: memberItem)
//                items.append(Item(memberItem: memberItem))
//            }
            
        }
        @MainActor func setDataSource(memberItem:[Item]){
            var snapshot = snapshot()
            let items = snapshot.itemIdentifiers(inSection: .member)
            snapshot.deleteItems(items)
            snapshot.appendItems(memberItem.shuffled())
            Task{@MainActor in
                await apply(snapshot,animatingDifferences: true)
            }
        }
        @MainActor func initDataSource(memberItem: [Item]){
            var snapshot = snapshot()
            snapshot.appendSections([.member,.dm])
            snapshot.appendItems(memberItem,toSection: .member)
            let dmItem = [Item(dmItem: .init(dmID: 1,sectionType: .dm)),Item(dmItem: .init(dmID: 2,sectionType: .dm))]
            snapshot.appendItems(dmItem,toSection: .dm)
            apply(snapshot,animatingDifferences: true)
        }
        @discardableResult
        func appendMemberAsset(memberItem:MemberListItem)-> MemberListAsset{
            let image = if let imageName = memberItem.userResponse.profileImage,let image = UIImage(named:imageName){
                image
            }else{ UIImage.noPhotoA}
            let asset = MemberListAsset(userId: memberItem.id, image: image)
            self.memberAssets.setObject(asset, forKey: asset.id as NSString)
            return asset
        }
    }
}
