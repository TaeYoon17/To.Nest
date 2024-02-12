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
        var infoItem = InfoItem()
        private(set) var memberListHeader: MemberListHeader!
        let memberListModel = AnyModelStore<CHMemberListItem>([])
        let memberListAssets = NSCache<NSString,MemberListAsset>()
        let editListModel = AnyModelStore<EditListItem>([])
        init(reactor: CHSettingReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SectionType, Item>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initHeaders()
            initMembers()
            initEdits()
//MARK: -- 정보(Info) 구성
            reactor.state.map{($0.title,$0.description)}.bind { [weak self] title,description in
                guard let self else {return}
                DispatchQueue.main.async{[weak self] in
                    guard let self else {return}
                    var snapshot = snapshot()
                    self.infoItem.title = title
                    self.infoItem.description = description
                    snapshot.reconfigureItems([Item(infoItem)])
                    apply(snapshot)
                }
            }.disposed(by: disposeBag)
//MARK: -- Edit 구성
            reactor.state.map{$0.ownerType}.distinctUntilChanged().bind(with: self) { owner, ownerType in
                guard let ownerType else {return}
                print("ownerType called \(ownerType)")
                switch ownerType{
                case .my:
                    let editListItems:[EditListItem] = [EditListItem(editingType: .edit),.init(editingType: .exit),
                                                        .init(editingType: .adminChange),.init(editingType: .delete)]
                    owner.editListModel.insertModel(items: editListItems)
                    DispatchQueue.main.async{
                        var snapshot = owner.snapshot()
                        var prevItems = snapshot.itemIdentifiers(inSection: .editing)
                        snapshot.deleteItems(prevItems)
                        let items = editListItems.map{Item($0)}
                        snapshot.appendItems(items, toSection: .editing)
                        owner.apply(snapshot,animatingDifferences: true)
                    }
                case .others:
                    let editListItems:[EditListItem] = [.init(editingType: .exit)]
                    Task{@MainActor in
                        var snapshot = owner.snapshot()
                        var prevItems = snapshot.itemIdentifiers(inSection: .editing)
                        snapshot.deleteItems(prevItems)
                        owner.editListModel.insertModel(items: editListItems)
                        let items = editListItems.map{Item($0)}
                        snapshot.appendItems(items, toSection: .editing)
                        owner.apply(snapshot)
                    }
                }
            }.disposed(by: disposeBag)
//MARK: -- 멤버 구성
            reactor.state.map{$0.members}.bind(with: self) { owner, responses in
                Task{
                    var memberListItems:[CHMemberListItem] = []
                    for response in responses{
                        let item = CHMemberListItem(userResponse: response)
                        memberListItems.append(item)
                        await owner.appendAssetCache(item: item)
                    }
                    owner.memberListModel.insertModel(items:memberListItems)
                    let items = memberListItems.map{Item($0)}
                    owner.memberListHeader.numbers = items.count
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
            var memberListItems:[CHMemberListItem] = []
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
extension CHSettingView.DataSource{
    @discardableResult
    func appendAssetCache(item:MemberListItem) async -> MemberListAsset{
        let response = item.userResponse
        let image = if let profileImage = response.profileImage,let imageData = await NM.shared.getThumbnail(profileImage){
            UIImage.fetchBy(data: imageData, type: .medium)
        }else{
            UIImage.noPhotoA
        }
        let listItem = MemberListAsset(userId: item.id, image: image)
        memberListAssets.setObject(listItem, forKey: listItem.id as NSString)
        return listItem
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
