//
//  AuthPresentView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class AuthPresentView: BaseVC,View{
    func bind(reactor: AuthViewReactor){
        appleBtn.rx.tap.map{Reactor.Action.appleSignIn}.bind(to: reactor.action).disposed(by: disposeBag)
        kakaoBtn.rx.tap.map{Reactor.Action.kakaoSignIn}.bind(to: reactor.action).disposed(by: disposeBag)
        emailBtn.rx.tap.map{Reactor.Action.emailSignIn}.bind(to: reactor.action).disposed(by: disposeBag)
        signUpBtn.rx.tap.map{Reactor.Action.signUp}.bind(to: reactor.action).disposed(by: disposeBag)
        reactor.state.map{$0.shouldDimsiss}.distinctUntilChanged().bind(with: self) { owner, val in
            guard val else {return}
            owner.dismiss(animated: true) {
                reactor.provider.authService.navigation.onNext(.dismissCompleted)
            }
        }.disposed(by: disposeBag)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    var disposeBag = DisposeBag()
    
    let appleBtn = {
        let btn = UIButton()
        btn.setImage(.appleSignin, for: .normal)
        return btn
    }()
    let kakaoBtn = {
        let btn = UIButton()
        btn.setImage(.kakaoSignin, for: .normal)
        return btn
    }()
    let emailBtn = {
        let btn = UIButton()
        btn.setImage(.emailSingIn, for: .normal)
        return btn
    }()
    let signInLabel = {
        let label = UILabel()
        label.attributedText = "또는".title2
        label.textColor = .text 
        label.font = FontType.title2.get()
        return label
    }()
    let signUpBtn = {
        let btn = UIButton()
        btn.config.foregroundColor(.accent).text("새롭게 회원가입하기", font: .title2).apply()
        return btn
    }()
    lazy var signStView = {
        let sign = [signInLabel,signUpBtn]
        let st = UIStackView(arrangedSubviews: sign)
        st.axis = .horizontal
        st.spacing = 4
        st.alignment = .center
        st.distribution = .fillProportionally
        return st
    }()
    lazy var stView = {
        let btns = [appleBtn,kakaoBtn,emailBtn]
        let st = UIStackView(arrangedSubviews: btns)
        btns.forEach { btn in
            btn.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
        }
        st.axis = .vertical
        st.spacing = 16
        return st
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func configureView() {
        view.backgroundColor = .gray1
    }
    override func configureLayout() {
        view.addSubview(stView)
        view.addSubview(signStView)
    }
    override func configureNavigation() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func configureConstraints() {
        signStView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(48)
            make.centerX.equalToSuperview()
        }
        stView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(35)
            make.bottom.equalTo(signStView.snp.top).inset(-16)
        }
        
    }
}
