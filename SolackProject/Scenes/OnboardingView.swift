//
//  Onboarding.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
final class OnboardingView:BaseVC,View{
//    private let titleLabel = UILabel()
    private let titleImage = UIImageView()
    private let imageView = UIImageView()
    private var startBtn = UIButton()
    var disposeBag = DisposeBag()
    let counterViewReactor = CounterViewReactor()
    func bind(reactor: CounterViewReactor) {
        
    }
    
    override func configureLayout() {
        [titleImage,imageView,startBtn].forEach{view.addSubview($0)}
    }
    
    override func configureConstraints() {
        titleImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(39)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(App.Contraints.multi)
        }
        imageView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(App.Contraints.def)
            make.centerY.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        startBtn.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(App.Contraints.multi)
            make.height.equalTo(App.Contraints.height)
        }
    }
    override func configureNavigation() {
    }
    override func configureView() {
        imageView.image = UIImage.onboarding
        imageView.contentMode = .scaleAspectFill
        titleImage.image = .onboardText1
        titleImage.contentMode = .scaleAspectFit
        startBtn.config.backgroundColor(.accent).cornerRadius(8).text("시작하기", font: .title2).foregroundColor(.white).apply()
        startBtn.rx.tap.bind(with: self) { owner, _ in
            let vc = AuthPresentView()
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                sheet.detents = [.custom(resolver: { context in
                    280
                })]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 10
            }
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
    }
}
