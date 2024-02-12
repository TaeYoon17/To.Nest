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
        reactor.state.map{$0.isClose}.distinctUntilChanged().delay(.microseconds(250), scheduler: MainScheduler.instance).bind(with: self) { owner, isClose in
            if isClose{
                Task{@MainActor in
                    owner.navigationController?.popToRootViewController(animated: true)
                }
            }
        }.disposed(by: disposeBag)
        reactor.state.map{$0.dialog}.distinctUntilChanged().subscribe(on: MainScheduler.instance).bind(with: self) { owner, type in
            guard let type else {return}
            switch type{
            case .adminChange:
                let vc = CHAdminChangeView()
                vc.reactor = CHAdminChangeReactor(provider: reactor.provider, channelID: reactor.channelID, channelTitle: reactor.title)
                let nav = UINavigationController(rootViewController: vc)
                owner.present(nav,animated: true)
            case .delete:
                let alert = SolackAlertVC(title: "채널 삭제", description: "정말 이 채널을 삭제하시겠습니까? 삭제 시 멤버/채팅 등 채널 내의 모든 정보가 삭제되며 복구할 수 없습니다.", infos: [], cancelTitle: "취소", cancel: {}, confirmTitle: "삭제", confirm: {[weak self] in
                    reactor.action.onNext(.deleteAction)
                })
                alert.modalPresentationStyle = .overFullScreen
                owner.present(alert, animated: false)
            case .edit:
                let vc = CHWriterView(reactor.provider, type: .edit(info: reactor.info))
                let nav = UINavigationController(rootViewController: vc)
                owner.present(nav,animated:true)
            case .exit:
                let alert = SolackAlertVC(title: "채널에서 나가기", description: "나가기를 하면 채널 목록에서 삭제됩니다.", infos: [], cancelTitle: "취소", cancel: {}, confirmTitle: "나가기", confirm: {})
                alert.modalPresentationStyle = .overFullScreen
                owner.present(alert, animated: false)
            }
        }.disposed(by: disposeBag)
    }
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource:DataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray2
    }
    override func configureView() {
        configureCollectionView()
        reactor?.action.onNext(.initAction)
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
