//
//  HomeVC+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import UIKit
import SnapKit
extension HomeVC{
    final class HomeDataSource: UICollectionViewDiffableDataSource<SectionType,Item>{
        let channelListModel = AnyModelStore<ChannelListItem>([])
        let directListModel = AnyModelStore<DirectListItem>([])
        let bottomModel = AnyModelStore<BottomItem>([])
        let headerModel = AnyModelStore<HeaderItem>([])
        init(vm: HomeVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SectionType,Item>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initChannel()
            initDirect()
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
        func initChannel(){
            let channelLists = [ChannelListItem(name: "a", messageCount: 12, isRecent: false),
                         .init(name: "b", messageCount: 21, isRecent: false),
                         .init(name: "c", messageCount: 99, isRecent: false),
                        .init(name: "d", messageCount: 11, isRecent: false)
                         ]
            channelLists.forEach { channelListModel.insertModel(item: $0)}
            let channelBottom = BottomItem(sectionType: .channel, name: "채널 추가하기")
            bottomModel.insertModel(item: channelBottom)
            let channelHeader = HeaderItem(sectionType: .channel, name: "채널")
            headerModel.insertModel(item: channelHeader)
            initSnapshot(list: channelLists.map{Item($0)}, bottom: Item(channelBottom), top: Item(channelHeader))
        }
        func initDirect(){
            let directLists = [DirectListItem(name: "캠퍼스지킴이", imageData: "ARKit", messageCount: 2, unreadExist: false),
                                .init(name: "Hue", imageData: "AsyncSwift", messageCount: 8, unreadExist: false),
                                .init(name: "테스트 코드 짜는 새싹이", imageData: "macOS", messageCount: 21, unreadExist: true),
                               .init(name: "Jack", imageData: "Metal", messageCount: 99, unreadExist: false)
                         ]
            directLists.forEach { directListModel.insertModel(item: $0)}
            let directBottom = BottomItem(sectionType: .direct, name: "새 메시지 시작")
            bottomModel.insertModel(item: directBottom)
            let directHeader = HeaderItem(sectionType: .direct, name: "다이렉트 메시지")
            headerModel.insertModel(item: directHeader)
            initSnapshot(list: directLists.map{Item($0)}, bottom: Item(directBottom), top: Item(directHeader))
        }
        @MainActor func initSnapshot(list:[Item],bottom:Item,top:Item){
            var snapshot = NSDiffableDataSourceSectionSnapshot<Item>()
            var items = list
            items.append(bottom)
            snapshot.append([top])
            snapshot.append(items,to: top)
            snapshot.expand([top])
            apply(snapshot,to:top.sectionType)
        }
    }
}
