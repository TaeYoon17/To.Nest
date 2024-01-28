//
//  ChatField+ImageViewer.swift
//  SolackProject
//
//  Created by 김태윤 on 1/26/24.
//

import Foundation
import UIKit
import SwiftUI
import RxSwift
extension ChatFields.ChatTextField{
    final class ImageViewer:UIView{
        private lazy var collectionView:UICollectionView = .init(frame: .zero, collectionViewLayout: ChatFields.ChatTextField.ImageViewer.layout)
        private var dataSource: UICollectionViewDiffableDataSource<String,Item>!
        var deleteItemID: PublishSubject<String> = .init()
        var updatedFileDatas: PublishSubject<[ImageViewerItem]> = .init()
        var disposeBag = DisposeBag()
        init(){
            super.init(frame: .zero)
            addSubview(collectionView)
            collectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            let cellRegi = registration
            dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
                collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
            })
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            var snapshot = NSDiffableDataSourceSnapshot<String,Item>()
            snapshot.appendSections(["a"])
            snapshot.appendItems([],toSection: "a")
            dataSource.apply(snapshot,animatingDifferences: true)
            updatedFileDatas
                .distinctUntilChanged()
                .bind(with: self) { (owner:ChatFields.ChatTextField.ImageViewer, datas) in
                Task{
                    await MainActor.run {
                        owner.applyDataSource(items:datas)
                    }
                }
            }.disposed(by: disposeBag)
        }
        required init(coder: NSCoder) { fatalError("Don't use storyboard") }
        @MainActor private func applyDataSource(items:[Item]){
            var snapshot = dataSource.snapshot()
            let prevItems = snapshot.itemIdentifiers(inSection: "a")
            let deleteItems = Set(prevItems).subtracting(Set(items)).map{$0}
            let newItems = Set(items).subtracting(Set(prevItems)).map{$0}
            snapshot.deleteItems(deleteItems)
            snapshot.appendItems(newItems, toSection: "a")
            dataSource.apply(snapshot,animatingDifferences: true)
        }
        func appendItem(){
            
        }
        func deleteItem(){
            
        }
        struct Item:Hashable,Identifiable,Equatable{
            var id:String{imageID}
            var imageID:String
            var image:UIImage
            static func ==(lhs: Item, rhs: Item) -> Bool {
                return lhs.id == rhs.id
            }
            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        }
    }

}

//MARK: -- 레이아웃과 셀
fileprivate extension ChatFields.ChatTextField.ImageViewer{
    static var layout: UICollectionViewCompositionalLayout{
        let size = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1), heightDimension: .fractionalHeight(1))
        let item  = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)), subitems: [item,item,item,item,item])
        group.interItemSpacing = .flexible(0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)
        var config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        return layout
    }
    var registration: UICollectionView.CellRegistration<UICollectionViewCell,Item>{
        UICollectionView.CellRegistration {[weak self] cell, indexPath, itemIdentifier in
            guard let self else {return}
            cell.contentConfiguration = UIHostingConfiguration(content: {
                ZStack(alignment: .bottomLeading){
                    Image(uiImage:itemIdentifier.image)
                        .resizable()
                        .frame(width: 44,height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(alignment: .topTrailing) {
                            Button{
                                self.deleteItemID.onNext(itemIdentifier.imageID)
                            }label: {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 18,height: 18)
                                    .tint(.text)
                                    .background{
                                        Circle().fill(.white)
                                    }
                            }.offset(x:4,y:-4)
                                .zIndex(10)
                        }
                }
                .frame(width: 50,height: 50)
            })
        }
    }
}
