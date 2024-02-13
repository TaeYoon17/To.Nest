//
//  CHSetting+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/24/24.
//

import UIKit
import SnapKit
import RxSwift

extension CHSettingView{
    func configureCollectionView(){
        collectionView.delegate = self
        collectionView.backgroundColor = .gray2
        let infoRegi = infoRegistration
        let memberRegi = memberRegistration
        let editRegi = editingRegistration
        let headerRegi = expandableSectionHeaderRegistration
        dataSource = .init(reactor: reactor!, collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            switch (itemIdentifier.sectionType,itemIdentifier.itemType){
            case (.member,.header): collectionView.dequeueConfiguredReusableCell(using: headerRegi, for: indexPath, item: itemIdentifier)
            case (.info,.listItem): collectionView.dequeueConfiguredReusableCell(using: infoRegi, for: indexPath, item: itemIdentifier)
            case (.member,.listItem): collectionView.dequeueConfiguredReusableCell(using: memberRegi, for: indexPath, item: itemIdentifier)
            case (.editing,.listItem):
                collectionView.dequeueConfiguredReusableCell(using: editRegi, for: indexPath, item: itemIdentifier)
            default: collectionView.dequeueConfiguredReusableCell(using: infoRegi, for: indexPath, item: itemIdentifier)
            }
//
        })
    }
}
extension CHSettingView:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
