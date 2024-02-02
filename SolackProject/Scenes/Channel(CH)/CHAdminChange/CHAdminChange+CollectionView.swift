//
//  CHAdminChange+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/2/24.
//

import Foundation
import UIKit
import SwiftUI
extension CHAdminChangeView{
    func configureCollectionView(){
        let cellRegi = cellRegistration
        collectionView.backgroundColor = .gray1
        self.dataSource = .init(reactor: CHAdminChangeReactor(), collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
    }
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,String>{
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                ChangeManagerListCell()
            })
        }
    }
}
