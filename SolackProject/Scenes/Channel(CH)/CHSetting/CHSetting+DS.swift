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
            initHeaders()
            initMembers()
            initEdits()
            reactor.state.map{$0.ownerType}.distinctUntilChanged().bind(with: self) { owner, ownerType in
                guard let ownerType else {return}
                print("ownerType called \(ownerType)")
                switch ownerType{
                case .my:
                    let editListItems:[EditListItem] = [EditListItem(editingType: .edit),.init(editingType: .exit),
                                                        .init(editingType: .adminChange),.init(editingType: .delete)]
                    owner.editListModel.insertModel(items: editListItems)
//                    Task{@MainActor in
                    DispatchQueue.main.async{
                        var snapshot = owner.snapshot()
                        let items = editListItems.map{Item($0)}
                        snapshot.appendItems(items, toSection: .editing)
                        owner.apply(snapshot,animatingDifferences: true)
                    }
                case .others:
                    let editListItems:[EditListItem] = [.init(editingType: .exit)]
                    Task{@MainActor in
                        var snapshot = owner.snapshot()
                        owner.editListModel.insertModel(items: editListItems)
                        let items = editListItems.map{Item($0)}
                        snapshot.appendItems(items, toSection: .editing)
                        owner.apply(snapshot)
                    }
                }
            }.disposed(by: disposeBag)
            reactor.state.map{$0.members}.bind(with: self) { owner, responses in
                Task{
                    var memberListItems:[MemberListItem] = []
                    for response in responses{
                        let item = MemberListItem(sectionType: .member, itemType: .listItem, userResponse: response)
                        memberListItems.append(item)
                        if let profileImage = response.profileImage,let imageData = await NM.shared.getThumbnail(profileImage){
                            let image = UIImage.fetchBy(data: imageData, type: .medium)
                            do{
                                try await image.appendWebCache(name: profileImage, type: .medium)
                            }catch{
                                print(error)
                            }
                        }
                    }
                    owner.memberListModel.insertModel(items:memberListItems)
                    let items = memberListItems.map{Item($0)}
                    owner.memberListHeader.numbers = items.count
                    print("Items",items,items
                        .count)
                    DispatchQueue.main.async{
                        var snapshot = owner.snapshot(for: .member)
                        snapshot.deleteAll()
                        var headerItem = Item(owner.memberListHeader)
                        snapshot.append([headerItem])
                        snapshot.append(items, to: headerItem)
                        snapshot.expand([headerItem])
                        owner.apply(snapshot,to:.member)
                        var tempSnapshot = owner.snapshot()
                        tempSnapshot.reconfigureItems([headerItem])
                        owner.apply(tempSnapshot,animatingDifferences: false)
                    }
                }
            }.disposed(by: disposeBag)
        }
        func initHeaders(){
            var snapshot = snapshot()
            snapshot.appendSections([.info])
            snapshot.appendItems([Item(infoItem)],toSection: .info)
            
            apply(snapshot)
        }
        func initMembers(){
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            var memberListItems:[MemberListItem] = []
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
            snapshot.appendSections([.editing])
            snapshot.appendItems([],toSection: .editing)
            apply(snapshot)
        }
    }
}
extension CHEditingType{
    var infoText:String{
        switch self{
        case .delete: "채널 삭제"
        case .edit: "채널 편집"
        case .exit: "채널 나가기"
        case .adminChange: "채널 관리자 변경"
        }
    }
}
