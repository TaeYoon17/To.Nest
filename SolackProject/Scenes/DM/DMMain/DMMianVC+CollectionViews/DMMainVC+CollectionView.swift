//
//  DMMainVC+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import UIKit
import SnapKit

extension DMMainVC:UICollectionViewDelegate{
    func configureCollectionView(reactor: DMMainReactor){
        let memberRegi = memberCellRegistration
        let dmRegi = dmCellRegistration
        let bottomRegi = seperatorRegistration(elementKind: "BottomSeperator")
        collectionView.delegate = self
        dataSource = .init(reactor: reactor, collectionView: collectionView, cellProvider: {[weak self] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier.sectionType{
            case .dm:
                collectionView.dequeueConfiguredReusableCell(using: dmRegi, for: indexPath, item: itemIdentifier)
            case .member:
                collectionView.dequeueConfiguredReusableCell(using: memberRegi, for: indexPath, item: itemIdentifier)
            }
        })
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind{
            case "BottomSeperator":
                return collectionView.dequeueConfiguredReusableSupplementary(using: bottomRegi, for: indexPath)
            default: return nil
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let identifer = dataSource.itemIdentifier(for: indexPath) else {return}
        guard let item = dataSource.roomModel.fetchByID(identifer.id) else {return}
        let vc = DMChatView()
        vc.reactor = DMChatReactor(reactor!.provider, roomID: item.roomID, userID: item.userID, title: item.userName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
