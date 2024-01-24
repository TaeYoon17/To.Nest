//
//  CHChatView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import Foundation
import UIKit
import RxSwift
class CHChatReactor{}
struct ChatItem:Hashable{
    var id = UUID()
    let images:[String]
}
extension CHChatView{
    class DataSource: UICollectionViewDiffableDataSource<String,ChatItem>{
        var bottomFinished: PublishSubject<()> = .init()
        init(reactor:CHChatReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, ChatItem>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            Task{
                for imageName in imageNames{
                    try await UIImage(named: imageName)?.appendWebCache(name: imageName,size:.init(width: 120, height: 80),isCover:false)
                }
                initDataSource()
                try await Task.sleep(for: .seconds(0.1))
                collectionView.scrollToBottom()
                bottomFinished.onNext(())
            }
        }
        var imageNames:[String]{ ["macOS","Metal","RealityKit","ARKit","C++"]}
        @MainActor func initDataSource(){
            var snapshot = NSDiffableDataSourceSnapshot<String,ChatItem>()
            snapshot.appendSections(["Hello"])
            var arr:[ChatItem] = []
            for i in (0..<5){
                let images = Array(self.imageNames.prefix(Int.random(in: 0..<6)))
                print(images)
                arr.append( ChatItem(images: images) )
            }
            snapshot.appendItems(arr, toSection: "Hello")
            apply(snapshot,animatingDifferences: true)
        }
    }
}
