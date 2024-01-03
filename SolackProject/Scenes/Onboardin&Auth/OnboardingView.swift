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
    func bind(reactor: OnboardingViewReactor) {
        startBtn.rx.tap.map{ Reactor.Action.auth}.bind(to: reactor.action).disposed(by: disposeBag)
        reactor.state.map{$0.isLoading && $0.signUp}.distinctUntilChanged().subscribe(with: self){ owner, val in
            guard val else {return}
            let vc = SignUpView()
            vc.reactor = .init(provider: reactor.provider)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav,animated: true)
        }.disposed(by: disposeBag)
        reactor.state.map{($0.isLoading , $0.signInType)}.subscribe(with: self){ owner,val in
            guard val.0,let signInType = val.1 else {return}
            switch signInType{
            case .apple:
                let vc = SignInEmailView()
                owner.present(vc,animated: true)
            case .email:
                let vc = SignInEmailView()
                owner.present(vc,animated: true)
            case .kakao:
                let vc = SignInEmailView()
                owner.present(vc,animated: true)
            }
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isLoading && $0.isAuthPresent}.throttle(.nanoseconds(1000), scheduler: MainScheduler.instance).subscribe(with: self) { owner, val in
            print(val)
            guard val else {return}
            let vc = AuthPresentView()
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                sheet.detents = [.custom(resolver: { context in
                    280
                })]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 10
            }
            vc.reactor = reactor.reactorForAuth()
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
    }
    private let titleImage = UIImageView()
    private let imageView = UIImageView()
    private var startBtn = UIButton()
    var disposeBag = DisposeBag()
    //    let onbardingViewReactor = OnboardingViewReactor()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
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
    }
}
