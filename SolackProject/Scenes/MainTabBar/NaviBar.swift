//
//  NaviBar.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import UIKit
import RxSwift
import RxCocoa
final class NaviBar: BaseView{
    @DefaultsState(\.myProfile) var data
    var workSpaceTap: ControlEvent<Void>!
    var updateMyProfileImage: PublishSubject<()> = .init()
    var title:String = ""{
        didSet{
            let attr = title.attr(type: FontType.title1)
            workSpaceLabel.attributedText = NSAttributedString(attr)
        }
    }
    @MainActor var wsImage:UIImage = UIImage(resource: .wsThumbnail){
        didSet{
            updateWSImage()
        }
    }
    var disposeBag = DisposeBag()
    var workSpace:UIButton = .init()
    var workSpaceLabel:UILabel = .init()
    var profile:UIButton = .init()
    override init() {
        super.init()
        self.workSpaceTap = workSpace.rx.tap
        self.backgroundColor = .systemBackground
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func configureLayout() {
        self.addSubview(workSpace)
        self.addSubview(workSpaceLabel)
        self.addSubview(profile)
    }
    override func configureConstraints() {
        workSpace.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        
        profile.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        workSpaceLabel.snp.makeConstraints { make in
            make.leading.equalTo(workSpace.snp.trailing).inset(-8)
            make.trailing.equalTo(profile.snp.leading).inset(-8)
            make.centerY.equalToSuperview()
        }
    }
    override func configureView() {
        updateWSImage()
        updateProfileImage()
        let attr = title.attr(type: FontType.title1)
        workSpaceLabel.attributedText = NSAttributedString(attr)
        workSpaceLabel.textColor = .text
        workSpaceLabel.lineBreakMode = .byTruncatingTail
        workSpaceLabel.numberOfLines = 1
        self.updateMyProfileImage.bind(with: self) { owner, _ in
            owner.updateProfileImage()
        }.disposed(by: disposeBag)
    }
    private func updateProfileImage(){
        guard let imageData = data, let image = try? UIImage.fetchBy(data: imageData, type: .small) else {
            profile.config.backgroundImage(.noPhotoA, mode: .scaleAspectFill).cornerRadius(8).apply()
            return
        }
        profile.config.backgroundImage(image, mode: .scaleAspectFill).cornerRadius(8).apply()
    }
    func updateWSImage(){
        Task{@MainActor in
            workSpace.config.backgroundColor(.accent).backgroundImage(wsImage, mode: .scaleAspectFit).cornerRadius(8).apply()
        }
    }
}
