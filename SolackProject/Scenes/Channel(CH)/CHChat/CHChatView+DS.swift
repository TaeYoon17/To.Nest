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
    final class DataSource: UICollectionViewDiffableDataSource<String,ChatItem.ID>{
        var bottomFinished: PublishSubject<()> = .init()
        var disposeBag = DisposeBag()
        var chatModel = AnyModelStore<ChatItem>([])
        var chatAssetModel = NSCache<NSString,ChatAssets>()
        private weak var collectionView: UICollectionView!
        deinit{
            print("채널 데이터 소스가 사라짐!!")
        }
        init(reactor:CHChatReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, ChatItem.ID>.CellProvider){
            super.init(collectionView: collectionView, cellProvider: cellProvider)
            initDataSource()
            self.collectionView = collectionView
            reactor.state.map{$0.sendChat}.throttle(.microseconds(200), scheduler: MainScheduler.instance)
                .bind { [weak self] type in
                    guard let self,let type else {return}
                    switch type{
                    case .create(let response):
                        Task{ await self.appendModels(responses: [response],goDown: true) }
                    case .dbResponse(let responses):
                        guard responses.count > 0 else {return}
                        Task{ await self.appendModels(responses: responses,goDown: true) }
                    case .socketResponse(let responses):
                        Task{ await self.appendModels(responses: [responses]) }
                    }
                }.disposed(by: disposeBag)
            collectionView.layer.opacity = 0
        }
        private func appendModels(responses:[ChatResponse],goDown:Bool = false) async {
            var items: [ChatItem.ID] = []
            for response in responses{
                // 이미 모델에 저장된 것은 추가하지 않음
                guard !chatModel.isExist(id: response.chatID) else {continue}
                let item:CHChatView.ChatItem = ChatItem(chatResponse: response)
                items.append(item.chatID)
                appendChatAssetModel(item: item)
                chatModel.insertModel(item: item)
            }
            await appendDataSource(items: items,goDown: goDown)
        }
        @MainActor func initDataSource(){
            var snapshot = NSDiffableDataSourceSnapshot<String,ChatItem.ID>()
            snapshot.appendSections(["Hello"])
            var arr:[ChatItem.ID] = []
            snapshot.appendItems(arr, toSection: "Hello")
            apply(snapshot,animatingDifferences: true)
        }
        @MainActor func appendDataSource(items:[ChatItem.ID],goDown:Bool = false) async{
            var snapshot = snapshot()
            snapshot.appendItems(items, toSection: "Hello")
            Task{@MainActor in
                await apply(snapshot,animatingDifferences: false)
                if goDown,collectionView.isScrollable{
                    let lastIdx = self.snapshot(for: "Hello").items.count
                    let lastIndexPath = IndexPath(item: lastIdx - 1, section: 0)
                    collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
                }
                if self.collectionView.layer.opacity == 0{
                    UIView.animate(withDuration: 0.2) {
                        self.collectionView.layer.opacity = 1
                    }
                }
            }
        }
        @discardableResult func appendChatAssetModel(item: CHChatView.ChatItem) -> ChatAssets{
            var images:[Image] = []
            for imageName in item.images{
                let image = UIImage.fetchBy(fileName: imageName, type: .messageThumbnail)
                images.append(Image(uiImage: image))
            }
            let image:Image? = if let profilefile = item.profileImage, !profilefile.isEmpty{
                Image(uiImage: UIImage.fetchBy(fileName: profilefile, type: .small))
            }else{nil}
            let chatAssets = ChatAssets(chatID: item.id, images: images,profileImage: image)
            chatAssetModel.setObject(chatAssets, forKey: "\(item.chatID)" as NSString)
            return chatAssets
        }
        
    }
}
