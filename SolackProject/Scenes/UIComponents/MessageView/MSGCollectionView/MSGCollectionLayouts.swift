//
//  MSGCollectionLayout.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//
import Foundation
import UIKit
import SwiftUI
extension MessageView{
    func configureCollectionView(reactor: MessageReactor){
//        collectionView.delegate = self
//        collectionView.prefetchDataSource = self
    }
    var layout: UICollectionViewCompositionalLayout{
        var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfig.backgroundColor = .white
        listConfig.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        return layout
    }
    
    var chatCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,MessageCellItem.ID>{
        fatalError("It must be override!!")
    }
}
