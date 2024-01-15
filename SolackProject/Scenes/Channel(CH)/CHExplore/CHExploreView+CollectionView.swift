//
//  CHExploreView+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import SnapKit
import UIKit
import SwiftUI
extension CHExploreView:UICollectionViewDelegate{
    func configureCollectionView(){
        collectionView.delegate = self
        var cellRegi = cellRegistration
        dataSource = .init(reactor: CHExploreReactor(),collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
extension CHExploreView{
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,String>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                ChannelListItemView(isRecent: true, name: itemIdentifier, count: 0,showCount: false)
            })
            cell.configurationUpdateHandler = { cell, state in
                var backConfig = cell.defaultBackgroundConfiguration()
                backConfig.backgroundInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                if state.isSelected{ backConfig.backgroundColor = UIColor.systemFill
                }else{ backConfig.backgroundColor = .gray1
                }
                cell.backgroundConfiguration = backConfig
            }
        }
    }
    var layout: UICollectionViewCompositionalLayout{
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.showsSeparators = false
        listConfig.backgroundColor = .gray1
        var layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
}
