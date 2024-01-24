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
        var layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    var chatCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,ChatItem>{
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.backgroundColor = .blue
            Task{
                var image:[Image] = []
                for  imageName in itemIdentifier.images {
                    do{
                        let uiimage = try await UIImage.fetchWebCache(name: imageName, size: .init(width: 120, height: 80))
                        image.append(Image(uiImage: uiimage))
                    }catch{
                        let uiimage = try UIImage(named: imageName)!.downSample(size: .init(width: 120, height: 80))
                        image.append(Image(uiImage: uiimage))
                    }
                }
                await MainActor.run {
                    cell.contentConfiguration = UIHostingConfiguration(content: {
                        ChatCell(realImage: image)
                    })
                    cell.layoutIfNeeded()
                }
            }
            
        }
    }
}
