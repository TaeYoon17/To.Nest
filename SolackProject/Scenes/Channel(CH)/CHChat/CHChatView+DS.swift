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
            reactor.state.map{$0.sendChat}.bind(with: self) { owner, type in
                guard let type else {return}
                Task{
                    switch type{
                    case .create(let response):
                        await owner.appendModels(responses: [response])
                        Task{@MainActor in
                            if collectionView.isScrollable{
                                let lastIdx = owner.snapshot(for: "Hello").items.count
                                let lastIndexPath = IndexPath(item: lastIdx - 1, section: 0)
                                collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                            }
                            UIView.animate(withDuration: 0.2) {
                                collectionView.layer.opacity = 1
                            }
                        }
                    case .dbResponse(let responses):
                        await owner.appendModels(responses: responses)
                        Task{@MainActor in
                            if collectionView.isScrollable{
                                let lastIdx = owner.snapshot(for: "Hello").items.count
                                let lastIndexPath = IndexPath(item: lastIdx - 1, section: 0)
                                collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                            }
                            UIView.animate(withDuration: 0.2) {
                                collectionView.layer.opacity = 1
                            }
                        }
                    case .socketResponse(let responses):
                        await owner.appendModels(responses: [responses])
                    }
                }
            }.disposed(by: disposeBag)
            collectionView.layer.opacity = 0
            
        }
        private func appendModels(responses:[ChatResponse]) async {
            var items: [ChatItem.ID] = []
            for response in responses{
                // 이미 모델에 저장된 것은 추가하지 않음
                guard !chatModel.isExist(id: response.chatID) else {continue}
                let item:CHChatView.ChatItem = ChatItem(chatResponse: response)
                items.append(item.chatID)
                appendChatAssetModel(item: item)
                chatModel.insertModel(item: item)
            }
            await appendDataSource(items: items)
        }
        @MainActor func initDataSource(){
            var snapshot = NSDiffableDataSourceSnapshot<String,ChatItem.ID>()
            snapshot.appendSections(["Hello"])
            var arr:[ChatItem.ID] = []
            snapshot.appendItems(arr, toSection: "Hello")
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor func appendDataSource(items:[ChatItem.ID]) async{
            var snapshot = snapshot()
            snapshot.appendItems(items, toSection: "Hello")
            await apply(snapshot,animatingDifferences: false)
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
