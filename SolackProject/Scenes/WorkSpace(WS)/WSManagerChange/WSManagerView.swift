//
//  WSManagerView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/13/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

final class WSManagerView: BaseVC,View,Toastable{
    var isShowKeyboard: CGFloat? = 0
    var toastY: CGFloat = 0
    var toastHeight: CGFloat = 0.0
    
    var disposeBag: DisposeBag = .init()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: ChangeManager.layout)
    var dataSource: DataSource!
    func bind(reactor: WSManagerReactor) {
        dialogAndCloseBind(reactor: reactor)
        reactor.action.onNext(.initAction)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func configureView() {
        configureCollectionView()
    }
    override func configureLayout() {
        view.addSubview(collectionView)
    }
    override func configureNavigation() {
        self.navigationItem.title = "워크스페이스 관리자 변경"
        self.navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.isModalInPresentation = true
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true){ }
        }.disposed(by: disposeBag)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
