//
//  HomeVC+CellRegistration.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import SnapKit
import UIKit
import SwiftUI
extension HomeVC{
    var layout:UICollectionViewCompositionalLayout{
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.itemSeparatorHandler = {[weak self]  (indexPath, listSeparatorConfiguration) -> UIListSeparatorConfiguration in
            guard let self = self, let now = dataSource.itemIdentifier(for: indexPath) else {return listSeparatorConfiguration}
            var listSeparatorConfiguration = listSeparatorConfiguration
            listSeparatorConfiguration.topSeparatorVisibility = .hidden
            if now.itemType == .header, !dataSource.snapshot(for: now.sectionType).isExpanded(now){
                listSeparatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                return listSeparatorConfiguration
            }
            if now.itemType == .bottom{
                listSeparatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            }else{
                listSeparatorConfiguration.bottomSeparatorVisibility = .hidden
            }
            return listSeparatorConfiguration
        }
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    var channelRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            let channel = dataSource.fetchChannel(item: itemIdentifier)
            cell.contentConfiguration = UIHostingConfiguration {
                ChannelListItemView(item: channel)
            }
            cell.indentationLevel = 0
        }
    }
    var directRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            let dm = dataSource.fetchDirect(item: itemIdentifier)
            cell.contentConfiguration = UIHostingConfiguration {
                DirectMsgListItemView(item: dm)
            }
            cell.indentationLevel = 0
        }
    }
    var expandableSectionHeaderRegistration:  UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
        UICollectionView.CellRegistration{[weak self] (cell, indexPath, item) in
            guard let self else {return}
            let header = dataSource.fetchHeader(item: item)
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.textProperties.font = FontType.title2.get()
            contentConfiguration.text = header.name
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure(options:.init(style: .header, isHidden: false, reservedLayoutWidth: nil, tintColor: .text))]
        }
    }
    var bottomRegistration:UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            var bottom = dataSource.fetchBottom(item: itemIdentifier)
            cell.contentConfiguration = UIHostingConfiguration {
                AppendListBottom(name: bottom.name)
            }
            cell.indentationLevel = 0
        }
    }
}
