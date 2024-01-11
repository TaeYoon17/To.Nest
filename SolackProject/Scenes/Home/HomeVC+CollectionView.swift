//
//  HomeVC+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import UIKit
import SnapKit
import SwiftUI
final class HomeVM{}

extension HomeVC:UICollectionViewDelegate{
    func configureCollectionView(){
        collectionView.delegate = self
        let directRegi = directRegistration
        let channelRegi = channelRegistration
        let expandRegi = expandableSectionHeaderRegistration
        let bottomRegi = bottomRegistration
        dataSource = .init(vm: vm, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let type = (itemIdentifier.itemType,itemIdentifier.sectionType)
            switch type{
            case (.header,_):
                return collectionView.dequeueConfiguredReusableCell(using: expandRegi, for: indexPath, item: itemIdentifier)
            case (.bottom,_):
                return collectionView.dequeueConfiguredReusableCell(using: bottomRegi, for: indexPath, item: itemIdentifier)
            case (.list,.channel):
                return collectionView.dequeueConfiguredReusableCell(using: channelRegi, for: indexPath, item: itemIdentifier)
            case (.list,.direct):
                return collectionView.dequeueConfiguredReusableCell(using: directRegi, for: indexPath, item: itemIdentifier)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }

}


