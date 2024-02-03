//
//  DMMainVC+CellRegistraion.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import SwiftUI
import UIKit

extension DMMainVC{
    var layout:UICollectionViewCompositionalLayout{
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
//        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let layout = UICollectionViewCompositionalLayout {[weak self] value, environment in
            guard let self ,let sectionType = SectionType.getByNumber(value) else {
                fatalError("Error Occured!!")
            }
            switch sectionType{
            case .dm:
                var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
                listConfig.showsSeparators = false
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
                return section
            case .member:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                return section
            }
        }
        return layout
    }
//    var memberCellRegistration : UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
//        
//        
//    }
}
