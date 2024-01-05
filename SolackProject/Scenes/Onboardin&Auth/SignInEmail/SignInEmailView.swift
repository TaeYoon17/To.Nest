//
//  SignInEmailView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
final class SignInEmailView: BaseVC{
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    
    }
    //MARK: -- 뷰 구성
    let scrollView = UIScrollView()
    let emailField = InputFieldView(field: "이메일", placeholder: "이메일을 입력하세요")
    let pwField = InputFieldView(field: "비밀번호", placeholder: "비밀번호를 입력하세요")
    let signInBtn = UIButton()
    lazy var stView = {
        let subViews = [emailField,pwField]
        let st = UIStackView(arrangedSubviews: subViews)
        st.axis = .vertical
        st.distribution = .fill
        st.alignment = .fill
        return st
    }()
    override func configureView() {
        signInBtn.config.backgroundColor(.accent).foregroundColor(.white).cornerRadius(8).text("로그인", font: .title2).apply()
    }
    override func configureLayout() {
        [scrollView,signInBtn].forEach{view.addSubview($0)}
        scrollView.addSubview(stView)
    }
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.isModalInPresentation = true
        self.navigationItem.title = "이메일 로그인"
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }
    }
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).inset(24)
            make.bottom.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        signInBtn.snp.makeConstraints  { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
    }
}
