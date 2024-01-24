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
                Text(item.description)
            })
        }
    }
    var memberRegistration:UICollectionView.CellRegistration<UICollectionViewCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            let image = try? examineImage.randomElement()?.downSample(type: .small)
            cell.contentConfiguration = UIHostingConfiguration(content: {
                VStack(alignment:.center){
                    if let image{
                        Image(uiImage: image)
                    }
                    Text("Hue").font(FontType.body.font)
                }
            })
        }
    }
    var editingRegistration: UICollectionView.CellRegistration<UICollectionViewListCell,Item>{
        UICollectionView.CellRegistration { [weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            cell.contentConfiguration = UIHostingConfiguration(content: {
                Button{
                    print("Channel Edit Button")
                }label:{
                    Text("채널 편집")
                        .font(FontType.title2.font)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8).strokeBorder(lineWidth: 2)
                        }
                }
            })
        }
    }
    var expandableSectionHeaderRegistration:  UICollectionView.CellRegistration<UICollectionViewListCell, Item>{
        UICollectionView.CellRegistration{[weak self] (cell, indexPath, item) in
            guard let self else {return}
            let header = dataSource.memberListHeader
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.textProperties.font = FontType.title2.get()
            contentConfiguration.text = "멤버 (\(header?.numbers ?? 0))"
            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure(options:.init(style: .header, isHidden: false, reservedLayoutWidth: nil, tintColor: .text))]
        }
    }
    var layout: UICollectionViewCompositionalLayout{
        var listConfig = UICollectionLayoutListConfiguration(appearance: .grouped)
        var layout = UICollectionViewCompositionalLayout.list(using: listConfig)
        var layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        return layout
    }
}
