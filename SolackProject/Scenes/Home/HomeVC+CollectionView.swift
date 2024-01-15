//
//  HomeVC+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift
final class HomeVM{
    let provider: ServiceProviderProtocol
    init(){
        self.provider = ServiceProvider()
    }
    init(_ provider:ServiceProviderProtocol){
        self.provider = provider
    }
}

extension HomeVC:UICollectionViewDelegate{
    func configureCollectionView(){
        collectionView.delegate = self
        let directRegi = directRegistration
        let channelRegi = channelRegistration
        let expandRegi = expandableSectionHeaderRegistration
        let bottomRegi = bottomRegistration
        dataSource = .init(reactor: self.reactor!, collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let type = (itemIdentifier.itemType,itemIdentifier.sectionType)
            switch type{
            case (.header,_):
                return collectionView.dequeueConfiguredReusableCell(using: expandRegi, for: indexPath, item: itemIdentifier)
            case (.bottom,_):
                return collectionView.dequeueConfiguredReusableCell(using: bottomRegi, for: indexPath, item: itemIdentifier)
            case (.list,.channel):
                return collectionView.dequeueConfiguredReusableCell(using: channelRegi, for: indexPath, item: itemIdentifier)
            case (.list,.direct):
                return collectionView.dequeueConfiguredReusableCell(using: directRegi, for: indexPath, item: itemIdentifier)
            case (.list, .team):
                return collectionView.dequeueConfiguredReusableCell(using: directRegi, for: indexPath, item: itemIdentifier)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else {return}
        let type = (item.itemType,item.sectionType)
        switch type{
        case (.header,_): break
        case (.bottom,.channel):
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(.init(title: "채널 생성", style: .default, handler: { [weak self] _ in
                guard let self, let reactor else {return}
                Observable.just(Reactor.Action.setPresent(.create)).bind(to: reactor.action).disposed(by: disposeBag)
            }))
            alert.addAction(.init(title: "채널 탐색", style: .default, handler: { [weak self] _ in
                guard let self, let reactor else {return}
                Observable.just(Reactor.Action.setPresent(.explore)).bind(to: reactor.action).disposed(by: disposeBag)
            }))
            alert.addAction(.init(title: "취소", style: .cancel))
            self.present(alert,animated: true)
        case (.bottom,.direct): break
        case (.bottom, .team):
            let vc = CHInviteView()
            let nav = UINavigationController(rootViewController: vc)
            nav.fullSheetSetting()
            self.present(nav, animated: true)
        case (.list,.channel):break
        case (.list,.direct):break
        case (.list, .team): break
        
        }
    }

}


