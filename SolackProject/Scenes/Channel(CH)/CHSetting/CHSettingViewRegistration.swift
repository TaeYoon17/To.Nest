//
//  CHSettingViewRegistration.swift
//  SolackProject
//
//  Created by 김태윤 on 1/24/24.
//

import UIKit
import SwiftUI
import SnapKit
import RxSwift
import RxCocoa
extension CHSettingView{
    var infoRegistration:UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration { [weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            var item = dataSource.infoItem
            cell.contentConfiguration = UIHostingConfiguration(content: {
                VStack(alignment:.leading,spacing: 10){
                    Text("#\(item.title)").font(FontType.title2.font)
                    if !item.description.isEmpty{
                        Text(item.description).font(FontType.body.font)
                    }
                }
            }).margins(.top,16)
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .gray2
            cell.backgroundConfiguration = backgroundConfig
        }
    }
    var memberRegistration:UICollectionView.CellRegistration<UICollectionViewCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            guard let item:CHMemberListItem = dataSource.memberListModel.fetchByID(itemIdentifier.id) else {return}
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .gray2
            cell.backgroundConfiguration = backgroundConfig
            Task{
                let asset = if let item: MemberListAsset = self.dataSource.memberListAssets.object(forKey: itemIdentifier.id as NSString){
                    item
                }else{
                    await self.dataSource.appendAssetCache(item: item)
                }
                await MainActor.run{
                    cell.contentConfiguration = UIHostingConfiguration(content: {
                        MemberButton(item: item, asset: asset) {[weak self] response in
                            guard let self else {return}
                            let vc = ProfileViewerVC(provider: reactor!.provider, userID: response.userID)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }).background(.gray2)
                        .margins(.all, 2)
                }
            }
        }
    }
    var editingRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration { [weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            guard let item = dataSource.editListModel.fetchByID(itemIdentifier.id) else {return}
            cell.contentConfiguration = UIHostingConfiguration(content: {
                    Button{
                        self.reactor!.action.onNext(.actionDialog(item.editingType))
                    }label:{
                        HStack{
                            Spacer()
                            Text(item.editingType.infoText).font(FontType.title2.font)
                            Spacer()
                        }.frame(maxHeight: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8).strokeBorder(lineWidth: 1.5)
                            }
                    }.frame(height: 44)
                    .tint(item.editingType == .delete ? .error : .text)
            }).margins(.vertical,4).margins(.horizontal,24)
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .gray2
            cell.backgroundConfiguration = backgroundConfig
        }
    }
    var expandableSectionHeaderRegistration:  UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
        UICollectionView.CellRegistration{[weak self] (cell, indexPath, item) in
            guard let self else {return}
            let header = dataSource.memberListHeader
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.textProperties.font = FontType.title2.get()
            contentConfiguration.text = "멤버 (\(header?.numbers ?? 0))"
            var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
            backgroundConfig.backgroundColor = .gray2
            cell.backgroundConfiguration = backgroundConfig
            cell.backgroundColor = .gray2
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure(options:.init(style: .header, isHidden: false, reservedLayoutWidth: .standard, tintColor: .text)),]
        }
    }
    var layout: UICollectionViewCompositionalLayout{
        var layout = UICollectionViewCompositionalLayout {[weak self] idx, environment in
            guard let self else {fatalError("왜 사라져?")}
            guard let sectionType = SectionType.getByNumber(idx) else {fatalError("이상한 숫자...")}
            switch sectionType {
            case .info:
                var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
                listConfig.backgroundColor = .gray2
                listConfig.showsSeparators = false
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
                return section
            case .member:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/5), heightDimension: .fractionalWidth(1/5)))
                let headerItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)))
                let itemGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension:
                        .fractionalWidth(1), heightDimension: .fractionalWidth(1/5)), subitems: [item,item,item,item,item])
                let itemHeader = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension:
                        .fractionalWidth(1), heightDimension: .estimated(44)),subitems: [headerItem])
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)), subitems: [itemHeader,itemGroup,itemGroup,itemGroup,itemGroup])
                let section = NSCollectionLayoutSection(group: group)
                return section
            case .editing:
                var listConfig = UICollectionLayoutListConfiguration(appearance: .plain)
                listConfig.backgroundColor = .gray2
                listConfig.showsSeparators = false
                let section = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: environment)
                section.contentInsets = .init(top: 8, leading: 0, bottom: 8, trailing: 0)
                return section
            }
        }
        return layout
    }
}

