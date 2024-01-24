//
//  WSEmptyView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/21/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
final class WSEmptyView:BaseVC{
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        createBtn.rx.tap.bind(with: self) { owner, _ in
            let vc = WSwriterView(.create, reactor: WScreateReactor(AppManager.shared.provider))
            let nav = UINavigationController(rootViewController: vc)
            nav.fullSheetSetting()
            self.present(nav,animated: true)
        }.disposed(by: disposeBag)
    }
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()
    let navBar = NaviBar()
    let createBtn = AuthBtn()
    override func configureLayout() {
        
        [titleLabel,descriptionLabel,imageView,createBtn,navBar].forEach { view.addSubview($0) }
    }
    override func configureConstraints() {
        navBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom).inset(-24)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).inset(-24)
        }
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(imageView.snp.width)
        }
        createBtn.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(44)
        }
    }
    override func configureView() {
        titleLabel.text = "워크스페이스를 찾을 수 없어요."
        titleLabel.font = FontType.title1.get()
        descriptionLabel.text = "관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요."
        descriptionLabel.textAlignment = .center
        titleLabel.textColor = .text
        descriptionLabel.textColor = .text
        descriptionLabel.font = FontType.body.get()
        imageView.image = .wsEmpty
        imageView.contentMode = .scaleAspectFit
        createBtn.text = "워크스페이스 생성"
        navBar.title = "No Workspace"
        view.backgroundColor = .white
        createBtn.isAvailable = true
    }
}
