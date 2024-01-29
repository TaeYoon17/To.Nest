//
//  CHChatView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import Foundation
import UIKit
import RxSwift

extension CHChatView{
    class DataSource: UICollectionViewDiffableDataSource<String,ChatItem>{
        var bottomFinished: PublishSubject<()> = .init()
        var disposeBag = DisposeBag()
        var chatModel = AnyModelStore<ChatItem>([])
//        let thumbnailSize:CGSize = .init(width: 120, height: 80)
        init(reactor:CHChatReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, ChatItem>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initDataSource()
            reactor.state.map{$0.chatList}.distinctUntilChanged().bind(with: self) { owner, responses in
                Task{
                    var items: [ChatItem] = []
                    for response in responses{
                        // 이미 모델에 저장된 것은 추가하지 않음
                        guard !owner.chatModel.isExist(id: response.chatID) else {continue}
                        for imageName in response.files{
                            guard !UIImage.isExistFileCache(name: imageName,type: .messageThumbnail) else { continue }
                            let image = UIImage.fetchBy(fileName: imageName, type: .messageThumbnail)
                            try await image.appendFileCache(name: imageName,type: .messageThumbnail,isCover:false)
                        }
                        let item = ChatItem(chatID: response.chatID, content: response.content, images: response.files, createdAt: response.createdAt.convertToDate())
                        items.append(item)
                        owner.chatModel.insertModel(item: item)
                    }
                    owner.appendDataSource(items: items)
                }
            }.disposed(by: disposeBag)
            Task{
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
            snapshot.appendItems(arr, toSection: "Hello")
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor func appendDataSource(items:[ChatItem]){
            var snapshot = snapshot()

            snapshot.appendItems(items, toSection: "Hello")
            apply(snapshot,animatingDifferences: false)
        }
    }
}
