//
//  CHChatViewRegistration.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import Foundation
import UIKit
import SwiftUI
extension CHChatView{
    var layout: UICollectionViewCompositionalLayout{
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .white
        listConfig.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    
    var chatCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,ChatItem.ID>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else{ fatalError("메모리 SELF 오류!!") }
            guard let item = dataSource.chatModel.fetchByID(itemIdentifier) else {return}
            cell.backgroundColor = .clear
            cell.selectedBackgroundView = .none
            if let itemAssets = dataSource.chatAssetModel.object(forKey: "\(item.chatID)" as NSString){
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    ChatCell(chatItem: item,images: itemAssets)
                })
            }else{
                let itemAsset = self.dataSource.appendChatAssetModel(item: item)
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    ChatCell(chatItem: item,images: itemAsset)
                })
            }
        }
    }
}
