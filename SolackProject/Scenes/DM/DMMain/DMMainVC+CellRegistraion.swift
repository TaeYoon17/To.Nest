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
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(76), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(98)), subitems: [item])
                group.interItemSpacing = .flexible(0)
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(1))
                section.boundarySupplementaryItems = [
//                    .init(layoutSize: size, elementKind: "TopSeperator", alignment: .top),
                    .init(layoutSize: size, elementKind: "BottomSeperator", alignment: .bottom),
                ]
                return section
            }
        }
    }
    var memberCellRegistration : UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            guard let item = dataSource.memberModel.fetchByID(itemIdentifier.id) else {return}
            let memberAsset = if let asset = dataSource.memberAssets.object(forKey: itemIdentifier.id as NSString){
                asset
            }else{
                dataSource.appendMemberAsset(memberItem: item)
            }
            cell.backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
            cell.backgroundConfiguration?.backgroundColor = .clear
            cell.contentConfiguration = UIHostingConfiguration(content: {
                HStack{
                    Spacer()
                    MemberButton(item: item, asset: memberAsset) { response in
                        print("선택 되었습니다.")
                    }
                    Spacer()
                }
            })
        }
    }
    var dmCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            cell.contentConfiguration = UIHostingConfiguration(content: {
                HStack(alignment:.top){
                    Image(.macOS).resizable().scaledToFill().frame(width: 34,height:34).clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(spacing:2) {
                        HStack{
                            Text("Hue").font(FontType.caption.font)
                            Spacer()
                            Text("2024년 1월 3일").font(FontType.caption2.font)
                        }
                        HStack(alignment:.top){
                            Text("Cause I know what you like boy You're my chemical hype boy 내 지난날들은 눈 뜨면 잊는 꿈 Hype boy 너만 원해 Hype boy 너만 원해").font(FontType.caption2.font)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                            Spacer()
                            Text("4")
                                .font(FontType.caption2.font)
                                .padding(.vertical,2).padding(.horizontal,4)
                                .background(.accent)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }.padding(.horizontal,8)
                }
            }).margins(.horizontal,16).margins(.vertical,6)
        }
    }
    func seperatorRegistration(elementKind:String) -> UICollectionView.SupplementaryRegistration<UICollectionReusableView>{
        UICollectionView.SupplementaryRegistration(elementKind: elementKind) {[weak self] supplementaryView, elementKind, indexPath in
            supplementaryView.backgroundColor = .sepa
        }
    }
}
