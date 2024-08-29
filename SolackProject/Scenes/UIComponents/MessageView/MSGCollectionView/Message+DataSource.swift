//
//  MessageDataSource.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import Foundation
import UIKit
import RxSwift
import ReactorKit
import SwiftUI
class MessageDataSource<MessageReactor:Reactor,CellItem:MessageCellItem,CellAsset:MessageAsset>: UICollectionViewDiffableDataSource<String,CellItem.ID>{
    var bottomFinished: PublishSubject<()> = .init()
    weak var collectionView:UICollectionView!
    var disposeBag = DisposeBag()
    var msgModel = AnyModelStore<CellItem>([])
    var msgAssetModel = NSCache<NSString,CellAsset>()
    init(reactor:MessageReactor,collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, CellItem.ID>.CellProvider){
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.initDataSource()
        self.collectionView = collectionView
        collectionView.layer.opacity = 0
    }
    @MainActor func initDataSource(){
        var snapshot = NSDiffableDataSourceSnapshot<String,CellItem.ID>()
        snapshot.appendSections(["Hello"])
        var arr:[CellItem.ID] = []
        snapshot.appendItems(arr, toSection: "Hello")
        apply(snapshot,animatingDifferences: true)
    }
    @MainActor func appendDataSource(items:[CellItem.ID],goDown:Bool = false) async{
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
    @discardableResult func appendChatAssetModel(item: MessageCellItem) -> MessageAsset{
        var images:[Image] = []
        for imageName in item.images{
            let image = UIImage.fetchBy(fileName: imageName, type: .messageThumbnail)
            images.append(Image(uiImage: image))
        }
        let profileImage:Image? = if let profileFile = item.profileImage?.webFileToDocFile(){
            
            Image(uiImage: UIImage.fetchBy(fileName: profileFile, type: .small))
        }else{nil}
        let msgAssets = CellAsset(messageID: item.id, images: images, profileImage: profileImage)
        msgAssetModel.setObject(msgAssets, forKey: "\(item.id)" as NSString)
        return msgAssets
    }
}

