//
//  WSManagerView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import SnapKit
import UIKit
import ReactorKit
extension WSManagerView{
    final class DataSource:UICollectionViewDiffableDataSource<String,String>{
        init(reactor: WSManagerReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, String>.CellProvider) {
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initSnapshot()
        }
        func initSnapshot(){
            var snapshot = NSDiffableDataSourceSnapshot<String,String>()
            snapshot.appendSections(["관리자"])
            snapshot.appendItems(["가","나","다"])
            apply(snapshot,animatingDifferences: true)
        }
    }
}
