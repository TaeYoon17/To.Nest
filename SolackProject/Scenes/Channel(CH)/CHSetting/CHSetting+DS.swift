//
//  CHSetting+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
extension CHSettingView{
    final class DataSource: UICollectionViewDiffableDataSource<SectionType,Item>{
        var disposeBag = DisposeBag()
        let infoItem = InfoItem()
        private(set) var memberListHeader: MemberListHeader!
        let memberListModel = AnyModelStore<MemberListItem>([])
        let editListModel = AnyModelStore<EditListItem>([])
        init(reactor: CHSettingReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SectionType, Item>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            var snapshot = NSDiffableDataSourceSnapshot<SectionType,Item>()
            snapshot.appendSections([.info,.member,.editing])
            apply(snapshot)
            initHeaders()
            initMembers()
            initEdits()
            
        }
        func initHeaders(){
            var snapshot = snapshot()
            snapshot.appendItems([Item(infoItem)],toSection: .info)
            apply(snapshot)
        }
        func initMembers(){
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            var memberListItems = [MemberListItem(name: "휴"),.init(name: "잭"),.init(name: "브랜")]
            memberListModel.insertModel(items:memberListItems)
            var items = memberListItems.map{Item($0)}
            memberListHeader = .init(numbers: items.count)
            var headerItem = Item(memberListHeader)
            sectionSnapshot.append([headerItem])
            sectionSnapshot.append(items, to: headerItem)
            sectionSnapshot.expand([headerItem])
            apply(sectionSnapshot, to: headerItem.sectionType)
        }
        func initEdits(){
            var snapshot = snapshot()
            var editListItems = [EditListItem(editingType: .edit),.init(editingType: .delete),.init(editingType: .exit)]
            editListModel.insertModel(items: editListItems)
            var items = editListItems.map{Item($0)}
            snapshot.appendItems(items,toSection: .editing)
            apply(snapshot)
        }
    }
}
