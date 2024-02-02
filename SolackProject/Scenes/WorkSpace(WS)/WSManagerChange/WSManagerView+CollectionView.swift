//
//  WSManagerView+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import UIKit
import SnapKit
import SwiftUI
extension WSManagerView:UICollectionViewDelegate{
    func configureCollectionView(){
        collectionView.backgroundColor = .gray1
        self.collectionView.delegate = self
        
        let regi = cellRegistration
        dataSource = .init(reactor: self.reactor!, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: regi, for: indexPath, item: itemIdentifier)
        })
    }
    var layout:UICollectionViewCompositionalLayout{
        var listCellConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listCellConfig.showsSeparators = false
        listCellConfig.backgroundColor = .gray1
        var layout = UICollectionViewCompositionalLayout.list(using: listCellConfig)
        return layout
    }
    var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell,String>{
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                WSChagneManagerListView()
            }).margins(.leading, 14).margins(.vertical, 8)
            
            cell.configurationUpdateHandler = { cell, state in
                var backConfig = cell.defaultBackgroundConfiguration()
                backConfig.backgroundInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
                if state.isSelected{
                    backConfig.backgroundColor = UIColor.systemFill
                }else{
                    backConfig.backgroundColor = .gray1
                }
                cell.backgroundConfiguration = backConfig
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
struct WSChagneManagerListView: View{
    var body: some View{
        HStack(spacing:8){
            Image(.arKit).resizable().scaledToFit().frame(width: 44,height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment:.leading,spacing:0){
                Text("Coutrney Henry")
                    .font(FontType.bodyBold.font)
                    .foregroundStyle(.text)
                    .frame(height: 18)
                
                Text(verbatim:"michelle.rivera@example.com")
                    .font(FontType.body.font)
                    .foregroundStyle(.secondary)
                    .frame(height:18)
            }
            Spacer()
        }
    }
}
