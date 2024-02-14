//
//  DMMainVC+CellRegistraion.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//

import SwiftUI
import UIKit

extension DMMainVC{
    var layout:UICollectionViewCompositionalLayout{
        UICollectionViewCompositionalLayout {[weak self] value, environment in
            guard let self ,let sectionType = SectionType.getByNumber(value) else {
                fatalError("Error Occured!!")
            }
            switch sectionType{
            case .dm:
                var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
                listConfig.showsSeparators = false
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
                section.contentInsets = .init(top: 16, leading: 0, bottom: 0, trailing: 0)
                return section
            case .member:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(74), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(98)), subitems: [item])
                group.interItemSpacing = .flexible(0)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(1))
                section.boundarySupplementaryItems = [
                    .init(layoutSize: size, elementKind: "BottomSeperator", alignment: .bottom),
                ]
                return section
            }
        }
    }
    var memberCellRegistration : UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            guard let item = dataSource.memberModel.fetchByID(itemIdentifier.id) else {
                fatalError("member item error")
                return
            }
            Task{
                let memberAsset = if let asset = self.dataSource.dmAssets.object(forKey: "\(item.userResponse.userID)" as NSString){
                    asset
                }else{
                    await self.dataSource.appendDMAsset(memberItem: item)
                }
                await MainActor.run {
                    cell.backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
                    cell.backgroundConfiguration?.backgroundColor = .clear
                    cell.contentConfiguration = UIHostingConfiguration(content: {
                        HStack{
                            Spacer()
                            MemberButton(item: item, asset: memberAsset) { (response:UserResponse) in
                                self.reactor!.action.onNext(.setRoom(response))
                            }
                            Spacer()
                        }
                    })
                }
            }
        }
    }
    var dmCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            guard let item = dataSource.roomModel.fetchByID(itemIdentifier.id) else {return}
            Task{
                let roomAsset = if let asset = self.dataSource.dmAssets.object(forKey: "\(item.userID)" as NSString){
                    asset
                }else{
                    await self.dataSource.appendDMAsset(roomItem: item)
                }
                await MainActor.run {
                    cell.contentConfiguration = UIHostingConfiguration(content: {
                        DMRoomCell(item: item, asset: roomAsset)
                    }).margins(.horizontal,16).margins(.vertical,6)
                }
            }
        }
    }
    func seperatorRegistration(elementKind:String) -> UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: elementKind) {[weak self] supplementaryView, elementKind, indexPath in
            supplementaryView.backgroundColor = .sepa
        }
    }
}
