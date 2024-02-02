//
//  CHAdminChange+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 2/2/24.
//

import UIKit
final class CHAdminChangeReactor{}
extension CHAdminChangeView{
    final class DataSource: UICollectionViewDiffableDataSource<String,String>{
        init(reactor: CHAdminChangeReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, String>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            self.initSnapshot()
        }
        func initSnapshot(){
            var snapshot = NSDiffableDataSourceSnapshot<String,String>()
            snapshot.appendSections(["관리자"])
            snapshot.appendItems(["가","나","다"])
            apply(snapshot,animatingDifferences: true)
        }
    }
    
}
