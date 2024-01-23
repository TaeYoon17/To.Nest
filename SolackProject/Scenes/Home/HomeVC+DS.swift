//
//  HomeVC+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import UIKit
import SnapKit
import RxSwift
extension HomeVC{
    final class HomeDataSource: UICollectionViewDiffableDataSource<SectionType,Item>{
        let channelListModel = AnyModelStore<ChannelListItem>([])
        let directListModel = AnyModelStore<DirectListItem>([])
        let bottomModel = AnyModelStore<BottomItem>([])
        let headerModel = AnyModelStore<HeaderItem>([])
        private var disposeBag = DisposeBag()
        init(reactor: HomeReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SectionType,Item>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initChannel()
            initDirect()
            initTeamOne()
            binding(reactor: reactor)
        }
        func binding(reactor: HomeReactor){
            reactor.state.map{$0.channelList}
                .bind(with: self, onNext: { (owner:HomeVC.HomeDataSource, response:[CHResponse]?) in
                    guard let response else {return}
                    guard let headerItem = owner.headerModel.fetchByID(SectionType.channel.rawValue) else {return}
                    let channelHeader = Item(headerItem)
                    print("channelHeader \(channelHeader) / \(headerItem)")
                    let channelBottom = BottomItem(sectionType: .channel, name: "채널 추가하기")
                    owner.bottomModel.insertModel(item: channelBottom)
                    let chListItems: [ChannelListItem] = response.map{.init(name: $0.name, messageCount: 1, isRecent: true)
                    }
                    chListItems.forEach({owner.channelListModel.insertModel(item: $0)})
                    var items = chListItems.map{Item($0)}
                    var snapshot = owner.snapshot(for: .channel)
                    snapshot.deleteAll()
                    items.append(Item(channelBottom))
                    snapshot.append([channelHeader])
                    snapshot.append(items, to: channelHeader)
                    snapshot.expand([channelHeader])
                    owner.apply(snapshot,to:channelHeader.sectionType)
                }).disposed(by: disposeBag)
        }
        func fetchDirect(item:Item) -> DirectListItem{
            directListModel.fetchByID(item.id)
        }
        func fetchChannel(item:Item) -> ChannelListItem{
            channelListModel.fetchByID(item.id)
        }
        func fetchHeader(item:Item) -> HeaderItem{
            headerModel.fetchByID(item.id)
        }
        func fetchBottom(item:Item) -> BottomItem{
            bottomModel.fetchByID(item.id)
        }
        func initChannel(channelLists:[ChannelListItem] = []){
            channelLists.forEach { channelListModel.insertModel(item: $0)}
            let channelBottom = BottomItem(sectionType: .channel, name: "채널 추가하기")
            bottomModel.insertModel(item: channelBottom)
            let channelHeader = HeaderItem(sectionType: .channel, name: "채널")
            headerModel.insertModel(item: channelHeader)
            initSnapshot(list: channelLists.map{Item($0)}, bottom: Item(channelBottom), top: Item(channelHeader))
        }
        func initDirect(){
            let directLists:[DirectListItem] = []
            directLists.forEach { directListModel.insertModel(item: $0)}
            let directBottom = BottomItem(sectionType: .direct, name: "새 메시지 시작")
            bottomModel.insertModel(item: directBottom)
            let directHeader = HeaderItem(sectionType: .direct, name: "다이렉트 메시지")
            headerModel.insertModel(item: directHeader)
            initSnapshot(list: directLists.map{Item($0)}, bottom: Item(directBottom), top: Item(directHeader))
        }
        func initTeamOne(){
            let teamBottom = BottomItem(sectionType: .team, name: "팀원 추가")
            bottomModel.insertModel(item: teamBottom)
            var snapshot = snapshot()
            snapshot.appendSections([.team])
            snapshot.appendItems([Item(teamBottom)])
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor func initSnapshot(list:[Item],bottom:Item,top:Item){
            var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            var items = list
            items.append(bottom)
            snapshot.append([top])
            snapshot.append(items,to: top)
            snapshot.expand([top])
            apply(snapshot,to:top.sectionType)
            print("Applied")
        }
    }
}
