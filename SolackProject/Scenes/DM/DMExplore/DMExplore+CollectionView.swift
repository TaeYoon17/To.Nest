//
//  DMInviteView+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import UIKit
import SwiftUI
import RxSwift
extension DMExplore:UICollectionViewDelegate{
    func configureCollectionView(reactor: DMExploreReactor){
        let cellRegi = cellRegistration
        collectionView.backgroundColor = .gray1
        collectionView.delegate = self
        self.dataSource = .init(reactor: reactor, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        self.reactor!.action.onNext(.goRoomsAction(userID: item.userID))
    }
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,ChangeManagerListItem>{
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                ChangeManagerListCell(item: itemIdentifier)
            }).margins(.leading, 14).margins(.vertical, 8)
            cell.configurationUpdateHandler = { cell, state in
                var backConfig = cell.defaultBackgroundConfiguration()
                backConfig.backgroundInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                if state.isSelected{
                    backConfig.backgroundColor = UIColor.systemFill
                }else{
                    backConfig.backgroundColor = .gray1
                }
                cell.backgroundConfiguration = backConfig
            }
        }
    }
}
