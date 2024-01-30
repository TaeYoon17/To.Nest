//
//  CHChatView+DS.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import Foundation
import UIKit
import RxSwift
import SwiftUI
extension CHChatView{
    class DataSource: UICollectionViewDiffableDataSource<String,ChatItem.ID>{
        var bottomFinished: PublishSubject<()> = .init()
        var disposeBag = DisposeBag()
        var chatModel = AnyModelStore<ChatItem>([])
        var chatAssetModel = NSCache<NSString,ChatAssets>()
        deinit{
            print("채널 데이터 소스가 사라짐!!")
        }
        init(reactor:CHChatReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, ChatItem.ID>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initDataSource()
            reactor.state.map{$0.chatList}.distinctUntilChanged().bind(with: self) { owner, responses in
                Task{
                    var items: [ChatItem.ID] = []
                    for response in responses{
                        // 이미 모델에 저장된 것은 추가하지 않음
                        guard !owner.chatModel.isExist(id: response.chatID) else {continue}
                        let item:CHChatView.ChatItem = ChatItem(chatResponse: response)
                        items.append(item.chatID)
                        owner.appendChatAssetModel(item: item)
                        owner.chatModel.insertModel(item: item)
                    }
                    owner.appendDataSource(items: items)
                }
            }.disposed(by: disposeBag)
            Task{

//                try await Task.sleep(for: .seconds(0.1))
                collectionView.scrollToBottom()
//                bottomFinished.onNext(())
            }
        }
        @MainActor func initDataSource(){
            var snapshot = NSDiffableDataSourceSnapshot<String,ChatItem.ID>()
            snapshot.appendSections(["Hello"])
            var arr:[ChatItem.ID] = []
            snapshot.appendItems(arr, toSection: "Hello")
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor func appendDataSource(items:[ChatItem.ID]){
            var snapshot = snapshot()
            snapshot.appendItems(items, toSection: "Hello")
            apply(snapshot,animatingDifferences: false)
        }
        
        @discardableResult func appendChatAssetModel(item: CHChatView.ChatItem) -> ChatAssets{
            var images:[Image] = []
            for imageName in item.images{
                let image = UIImage.fetchBy(fileName: imageName, type: .messageThumbnail)
                images.append(Image(uiImage: image))
            }
            let chatAssets = ChatAssets(chatID: item.chatID, images: images)
            chatAssetModel.setObject(chatAssets, forKey: "\(item.chatID)" as NSString)
            return chatAssets
        }
        
    }
}
