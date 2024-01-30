//
//  CHChatCollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import UIKit
import SnapKit
import RxSwift
extension CHChatView:UICollectionViewDelegate,UICollectionViewDataSourcePrefetching{
    func configureCollectionView(){
//        collectionView.alpha = 0
        collectionView.delegate = self
                collectionView.prefetchDataSource = self
        let cellRegi = chatCellRegistration
        dataSource = .init(reactor: reactor!, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
//        dataSource.bottomFinished.delay(.milliseconds(150), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, _ in
//            UIView.animate(withDuration: 0.2) {
//                owner.collectionView.alpha = 1
//            }
//        }.disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        indexPaths.forEach { indexPath in
            guard let itemID = dataSource.itemIdentifier(for: indexPath) else {return}
            guard dataSource.chatAssetModel.object(forKey: "\(itemID)" as NSString) != nil else {return}
            guard let item = dataSource.chatModel.fetchByID(itemID) else {return}
            dataSource.appendChatAssetModel(item: item)
        }
    }
}
