//
//  CHSettingView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
final class CHSettingView: BaseVC, View{
    var disposeBag = DisposeBag()
    func bind(reactor: CHSettingReactor) {
    }
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource:DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray2
    }
    override func configureView() {
        configureCollectionView()
    }
    override func configureLayout() {
        view.addSubview(collectionView)
    }
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = .getBackBtn
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "채널 설정"
        self.navigationItem.titleView = label
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.horizontalEdges.equalToSuperview()
        }
    }

}
