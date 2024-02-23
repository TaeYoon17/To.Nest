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
                    ChatCell(chatItem: item,images: itemAssets, profileAction: self.profileAction(userID:), imageAction: self.imageAction)
                }).background(.white)
            }else{
                let itemAsset = self.dataSource.appendChatAssetModel(item: item)
                cell.contentConfiguration = UIHostingConfiguration(content: {
                    ChatCell(chatItem: item,images: itemAsset, profileAction: self.profileAction(userID:), imageAction: self.imageAction)
                }).background(.white)
            }
        }
    }
    private func imageAction(imageURLs:[String]){
        print("여기 탭탭탭")
        let vc = ImageViewer()
        vc.imagePathes = imageURLs
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    private func profileAction(userID:Int){
        let vc = ProfileViewerVC(provider: reactor!.provider, userID: userID)
        navigationController?.pushViewController(vc, animated: true)
    }
}
