//
//  CHChatCollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/19/24.
//

import UIKit
import SnapKit
import RxSwift
extension CHChatView:UICollectionViewDelegate,UICollectionViewDataSourcePrefetching{

    func configureCollectionView(){
        collectionView.alpha = 0
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        let cellRegi = chatCellRegistration
        dataSource = .init(reactor: CHChatReactor(), collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
        dataSource.bottomFinished.delay(.milliseconds(150), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, _ in
            UIView.animate(withDuration: 0.2) {
                owner.collectionView.alpha = 1
            }
        }.disposed(by: disposeBag)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    var imageNames:[String]{
        ["macOS","Metal","RealityKit","ARKit","C++"]
    }
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("프리팻칭")
        indexPaths.forEach { indexPath in
            let images = Array(self.imageNames.prefix(Int.random(in: 0..<6)))
            Task{
                for imageName in images{
                    guard let image = UIImage(named: imageName) else {return}
                    do{
                        try await image.appendWebCache(name: imageName,size: .init(width: 120, height: 80),isCover: false)
                    }catch{
                        print("이게 안되네...")
                    }
                }
            }
        }
    }
}
