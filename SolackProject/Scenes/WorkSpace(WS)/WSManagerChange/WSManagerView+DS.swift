//
//  WSManagerView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import SnapKit
import UIKit
import ReactorKit
import RxSwift
import SwiftUI
import RxCocoa

extension WSManagerView{
    final class DataSource:UICollectionViewDiffableDataSource<String,ChangeManagerListItem>{
        @DefaultsState(\.userID) var userID
        var disposeBag = DisposeBag()
        
        init(reactor: WSManagerReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, ChangeManagerListItem>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initSnapshot()
            reactor.state.map{$0.members}.distinctUntilChanged().delay(.microseconds(100), scheduler: MainScheduler.instance).bind { [weak self] res in
                guard let self else {return }
                Task{
                    var items:[ChangeManagerListItem] = []
                    for response in res{
                        if response.userID == self.userID {continue}
                        let image = if let imageURL = response.profileImage,let imageData = await NM.shared.getThumbnail(imageURL){
                            Image(uiImage:UIImage.fetchBy(data: imageData, type: .small))
                        }else{
                            Image(uiImage:UIImage.noPhotoA)
                        }
                        let item = ChangeManagerListItem(userID: response.userID, nickName: response.nickname, profileImage: image, email: response.email)
                        items.append(item)
                    }
                    await MainActor.run {
                        self.updateSnapshot(items: items)
                    }
                }
            }.disposed(by: disposeBag)
        }
        @MainActor func initSnapshot(){
            var snapshot = NSDiffableDataSourceSnapshot<String,ChangeManagerListItem>()
            snapshot.appendSections(["관리자"])
            snapshot.appendItems([])
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor func updateSnapshot(items: [ChangeManagerListItem]){
            var snapshot = snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections(["관리자"])
            snapshot.appendItems(items,toSection: "관리자")
            apply(snapshot,animatingDifferences: false)
        }
    }
}
