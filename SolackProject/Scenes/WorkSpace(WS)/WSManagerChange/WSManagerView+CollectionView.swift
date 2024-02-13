//
//  WSManagerView+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import UIKit
import SnapKit
import SwiftUI
extension WSManagerView:UICollectionViewDelegate{
    func configureCollectionView(){
        collectionView.backgroundColor = .gray1
        self.collectionView.delegate = self
        
        let regi = cellRegistration
        dataSource = .init(reactor: self.reactor!, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: regi, for: indexPath, item: itemIdentifier)
        })
    }
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell,ChangeManagerListItem>{
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {return}
        reactor!.action.onNext(.changeAdminAction(userName: itemIdentifier.nickName, userID: itemIdentifier.userID))
    }
}
