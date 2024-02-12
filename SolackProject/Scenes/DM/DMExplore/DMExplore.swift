//
//  DMInviteView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
final class DMExplore: BaseVC,View,Toastable{
    var isShowKeyboard: CGFloat? = nil
    var toastY: CGFloat{ self.collectionView.frame.maxY - (toastHeight / 2) }
    var toastHeight: CGFloat = 0
    
    var disposeBag = DisposeBag()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: ChangeManager.layout)
    var dataSource: DataSource!
    func bind(reactor: DMExploreReactor) {
        configureCollectionView(reactor: reactor)
        dialogAndCloseBind(reactor: reactor)
        reactor.action.onNext(.initAction)
    }
    override func configureView() { }
    override func configureLayout() {
        self.view.addSubview(collectionView)
    }
    override func configureNavigation() {
        self.navigationItem.title = "새 메시지 시작"
        self.navigationItem.leftBarButtonItem = .init(image: .close)
        navigationItem.leftBarButtonItem?.tintColor = .text
        self.isModalInPresentation = true
        navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
