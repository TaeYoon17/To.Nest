//
//  WSEmpty.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
import SnapKit
import UIKit
import RxCocoa
import RxSwift
final class WSEmpty: BaseView{
    var btnTapped:ControlEvent<Void>!
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()
    let createBtn = AuthBtn()
    override func configureView() {
        titleLabel.text = "워크스페이스를 찾을 수 없어요."
        titleLabel.font = FontType.title1.get()
        descriptionLabel.text = "관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요."
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 2
        titleLabel.textColor = .text
        descriptionLabel.textColor = .text
        descriptionLabel.font = FontType.body.get()
        imageView.image = .wsEmpty
        imageView.contentMode = .scaleAspectFit
        createBtn.text = "워크스페이스 생성"
        self.backgroundColor = .white
        createBtn.isAvailable = true
        self.btnTapped = createBtn.rx.tap
    }
    override func configureLayout() {
        [titleLabel,descriptionLabel,imageView,createBtn].forEach { addSubview($0) }
    }
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self).inset(35)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).inset(-24)
        }
        imageView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self).offset(-44)
            make.horizontalEdges.equalToSuperview().inset(12)
            make.height.equalTo(imageView.snp.width)
        }
        createBtn.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(self).inset(24)
            make.height.equalTo(44)
        }
    }
}
