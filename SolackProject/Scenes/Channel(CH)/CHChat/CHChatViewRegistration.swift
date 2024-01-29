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
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            cell.backgroundColor = .blue
            Task{[weak self] in
                guard let self else{
                    fatalError("메모리 SELF 오류!!")
                }
                var image:[Image] = []
                for  imageName in itemIdentifier.images {
                    do{
                        let uiimage = try await UIImage.fetchFileCache(name: imageName,type: .messageThumbnail)
                        image.append(Image(uiImage: uiimage))
                    }catch{
                        let uiimage = UIImage.fetchBy(fileName: imageName, type: .messageThumbnail)
                        image.append(Image(uiImage: uiimage))
                    }
                }
                await MainActor.run {
                    cell.contentConfiguration = UIHostingConfiguration(content: {
//                        ChatCell(realImage: image)
                        ChatCell(message: itemIdentifier.content ?? "",realImage:image)
                    })
                    cell.layoutIfNeeded()
                }
            }
            
        }
    }
    
}
