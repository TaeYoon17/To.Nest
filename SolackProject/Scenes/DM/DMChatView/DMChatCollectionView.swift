//
//  DMChatCollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/7/24.
//

import UIKit
import SnapKit
import RxSwift
import SwiftUI
extension DMChatView:UICollectionViewDelegate,UICollectionViewDataSourcePrefetching{
    func configureCollectionView(reactor: DMChatReactor) {
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        let cellRegi = chatCellRegistration
        dataSource = .init(reactor: reactor, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
    }
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            guard let itemID = dataSource.itemIdentifier(for: indexPath) else {return}
            guard dataSource.msgAssetModel.object(forKey: "\(itemID)" as NSString) != nil else {return}
            guard let item = dataSource.msgModel.fetchByID(itemID) else {return}
            dataSource.appendChatAssetModel(item: item)
        }
    }
    var chatCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, MessageCellItem.ID>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {fatalError("메모리 오류!!")}
            guard let item:DMCellItem = dataSource.msgModel.fetchByID(itemIdentifier) else {return}
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = .none
            if let itemAssets = dataSource.msgAssetModel.object(forKey: "\(item.id)" as NSString){
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    MessageCell(msgItem: item, images: itemAssets)
                })
            }else{
                let itemAsset = self.dataSource.appendChatAssetModel(item: item)
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    MessageCell(msgItem: item, images: itemAsset)
                })
            }
        }
    }
}
