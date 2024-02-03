//
//  DMMainVC+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import UIKit
import SnapKit

extension DMMainVC{
    final class DataSource:UICollectionViewDiffableDataSource<SectionType,Item>{
        init(reactor: DMMainReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<DMMainVC.SectionType, DMMainVC.Item>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
        }
    }
}
