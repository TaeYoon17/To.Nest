//
//  DMChatViewDS.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit
import SnapKit
import RxSwift
import SwiftUI
extension DMChatView{
    final class DMDataSource: MessageDataSource<DMChatReactor,DMCellItem,DMAsset>{
        override init(reactor: DMChatReactor, collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<String, DMCellItem.ID>.CellProvider) {
            super.init(reactor: reactor, collectionView: collectionView, cellProvider: cellProvider)
            reactor.state.map{$0.sendChat}
                .bind { [weak self] chatType in
                guard let self,let chatType else {return}
                    switch chatType{
                    case .create(let response):
                        Task{ await self.appendModels(responses:response,goDown:true) }
                    case .dbResponse(let dbResponse):
                        guard !dbResponse.isEmpty else {return}
                        Task{ await self.appendModels(responses:dbResponse,goDown: true) }
                    case .socketResponse(let responses):
                        Task{ await self.appendModels(responses:responses) }
                    }
            }.disposed(by: disposeBag)
        }
        private func appendModels(responses:[DMResponse],goDown:Bool = false) async {
            var items:[DMCellItem.ID] = []
            for response in responses{
                let item:DMCellItem = DMCellItem(response: response)
                guard !msgModel.isExist(id: item.id) else {continue}
                items.append(item.dmID)
                appendChatAssetModel(item: item)
                msgModel.insertModel(item: item)
            }
            await appendDataSource(items: items, goDown: goDown)
        }
    }
}
