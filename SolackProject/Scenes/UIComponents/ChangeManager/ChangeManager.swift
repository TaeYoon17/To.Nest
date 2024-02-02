//
//  ChangeManagerComponents.swift
//  SolackProject
//
//  Created by 김태윤 on 2/2/24.
//

import UIKit
import SwiftUI
enum ChangeManager{
    static var layout:UICollectionViewCompositionalLayout{
        var listCellConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listCellConfig.showsSeparators = false
        listCellConfig.backgroundColor = .gray1
        var layout = UICollectionViewCompositionalLayout.list(using: listCellConfig)
        return layout
    }
    static var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell,String>{
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                ChangeManagerListCell()
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
