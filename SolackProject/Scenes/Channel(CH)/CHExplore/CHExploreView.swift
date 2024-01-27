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
    var vm:CHExploreVM!
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource:DataSource!
    var disposeBag = DisposeBag()
    func binding(){
        vm.alerts.subscribe(on: MainScheduler.instance).bind(with: self) { owner, alertType in
            switch alertType{
            case .join(chID: let id, chName: let name):
                let vc = SolackAlertVC(title: "채널 참여", description: "[\(name)] 채널에 참여하시겠습니까?", cancelTitle: "취소", cancel: {}, confirmTitle: "확인") {
                    owner.vm.moveChatting.onNext((id,name))
                }
                owner.present(vc,animated: false)
            }
        }.disposed(by: disposeBag)
        vm.moveChatting.subscribe(on: MainScheduler.instance).bind(with: self) { owner, chID in
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureView() {
        view.backgroundColor = .gray1
        configureCollectionView()
        binding()
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
