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
            owner.authSheetSetting(nav: nav)
            owner.present(nav,animated: true)
        }.disposed(by: disposeBag)
        reactor.state.map{($0.isLoading , $0.signInType)}.subscribe(with: self){ owner,val in
            let (a,b) = val
            guard a, let signInType = b else {return}
            switch signInType{
            case .apple:
                owner.appleLoginButtonClicked()
            case .email:
                let vc = SignInEmailView()
                let nav = UINavigationController(rootViewController: vc)
                vc.reactor = .init(provider: reactor.provider)
                owner.authSheetSetting(nav: nav)
                owner.present(nav,animated: true)
            case .kakao:
                reactor.action.onNext(.signInWithKakaoTalk)
                
            }
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isLoading && $0.isAuthPresent}.throttle(.nanoseconds(1000), scheduler: MainScheduler.instance).subscribe(with: self) { owner, val in
            guard val else {return}
            let vc = AuthPresentView()
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                let sheetHeight:UISheetPresentationController.Detent = .custom(resolver: { context in 280})
                sheet.detents = [sheetHeight]
                sheet.prefersGrabberVisible = true
                sheet.selectedDetentIdentifier = sheetHeight.identifier
                sheet.preferredCornerRadius = 10
            }
            vc.reactor = reactor.reactorForAuth()
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
    }
//    private let titleImage = UIImageView()
    private let titleLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.text = "To.Nest로 팀을 꾸리고\n각자의 관심사에 대해 소통하세요"
        label.numberOfLines = 2
        return label
    }()
    private let imageView = UIImageView()
    private var startBtn = AuthBtn()
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    }
    override func configureLayout() {
        [titleLabel,imageView,startBtn].forEach{view.addSubview($0)}
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
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
//        titleImage.image = .onboardText1
//        titleImage.contentMode = .scaleAspectFit
        startBtn.text = "시작하기"
        startBtn.isAvailable = true
    }
}
extension OnboardingView{
    func authSheetSetting(nav: UINavigationController){
        if let sheet = nav.sheetPresentationController{
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.selectedDetentIdentifier = .large
            sheet.preferredCornerRadius = 10
        }
    }
}

