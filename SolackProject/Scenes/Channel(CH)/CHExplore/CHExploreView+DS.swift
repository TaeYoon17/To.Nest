//
//  CHExploreView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import UIKit
import SnapKit
import RxSwift
extension CHExploreView{
    struct Item:Identifiable,Hashable{
        var id:Int{ channelID }
        var channelID:Int
        var name:String
    }
}
extension CHExploreView{
    final class DataSource: UICollectionViewDiffableDataSource<String,Item>{
        private var disposeBag = DisposeBag()
        var myChannelModel = AnyModelStore<Item>([])
        init(vm: CHExploreVM,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, Item>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initSnapshot()
            vm.allChannels
                .subscribe(on: MainScheduler.asyncInstance)
                .bind(with: self) { (owner:DataSource, response:[CHResponse]) in
                    var snapshot = owner.snapshot()
                    snapshot.deleteAllItems()
                    snapshot.appendSections(["탐색"])
                    snapshot.appendItems(response.map{Item(channelID: $0.channelID, name: $0.name)},toSection: "탐색")
                    Task{@MainActor in
                        await MainActor.run {
                            owner.apply(snapshot,animatingDifferences: true)
                        }
                    }
                }.disposed(by: disposeBag)
            vm.myChannels.subscribe(on: MainScheduler.asyncInstance)
                .bind(with: self) { (owner:DataSource, response:[CHResponse]) in
                    response.forEach{
                        let item = Item(channelID: $0.channelID, name: $0.name)
                        owner.myChannelModel.insertModel(item: item)
                    }
                }.disposed(by: disposeBag)
        }
        func isMyChannel(item:Item)-> Bool{
            if let item = myChannelModel.fetchByID(item.id){ true }else{ false }
        }
        @MainActor func initSnapshot(){
            var snapshot = NSDiffableDataSourceSnapshot<String,Item>()
            snapshot.appendSections(["탐색"])
            snapshot.appendItems([], toSection: "탐색")
            Task{@MainActor in
                await MainActor.run {
                    apply(snapshot,animatingDifferences: true)
                }
            }
        }
    }
}
