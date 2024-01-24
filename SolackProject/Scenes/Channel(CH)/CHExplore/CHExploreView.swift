//
//  CHExploreView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//
import SnapKit
import UIKit
import RxCocoa
import RxSwift
final class CHExploreView: BaseVC{
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource:DataSource!
    var disposeBag = DisposeBag()
    override func configureView() {
        view.backgroundColor = .gray1
        configureCollectionView()
    }
    override func configureLayout() {
        self.view.addSubview(collectionView)
    }
    override func configureNavigation() {
        self.navigationItem.title = "채널 탐색"
        self.navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
