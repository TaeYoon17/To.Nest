//
//  DMMainVC+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import UIKit
import SnapKit

extension DMMainVC{
    func configureCollectionView(reactor: DMMainReactor){
        
        dataSource = .init(reactor: reactor, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
        })
    }
}
