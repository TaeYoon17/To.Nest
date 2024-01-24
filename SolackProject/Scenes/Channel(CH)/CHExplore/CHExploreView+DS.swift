//
//  CHExploreView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import UIKit
import SnapKit
final class CHExploreReactor{
    
}
extension CHExploreView{
    final class DataSource: UICollectionViewDiffableDataSource<String,String>{
        init(reactor: CHExploreReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, String>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initSnapshot()
        }
        func initSnapshot(){
            var snapshot = NSDiffableDataSourceSnapshot<String,String>()
            snapshot.appendSections(["탐색"])
            snapshot.appendItems(["이것이 레거시다","취준이직정보방","code-review"], toSection: "탐색")
            apply(snapshot,animatingDifferences: true)
        }
    }
}
