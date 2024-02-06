//
//  DMChatViewDS.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit
import SnapKit

extension DMChatView{
    final class DMDataSource: MessageDataSource<DMChatReactor,DMCellItem,DMAsset>{
        var model = AnyModelStore<DMCellItem>([])
        override init(reactor: DMChatReactor, collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, DMCellItem.ID>.CellProvider) {
            super.init(reactor: reactor, collectionView: collectionView, cellProvider: cellProvider)
        }
    }
}
