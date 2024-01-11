//
//  WriteWorkSpaceView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
final class WSwriterView<Reactor: WSwriterReactor>:BaseVC,View{
    var disposeBag: DisposeBag = DisposeBag()
    
    let scrollView = UIScrollView()
    lazy var stView = {
        let arr = [workSpaceName,workSpaceDescription]
        let st = UIStackView(arrangedSubviews: arr)
        st.axis = .vertical
        st.spacing = 8
        st.distribution = .fill
        st.alignment = .fill
        return st
    }()
    var profileVC = ProfileImgVC()
    var workSpaceName = InputFieldView(field: "워크스페이스 이름", placeholder: "워크스페이스 이름을 입력하세요 (필수)", accessoryText: "완료")
    var workSpaceDescription = InputFieldView(field: "워크스페이스 설명", placeholder: "워크스페이스를 설명하세요 (옵션)", accessoryText: "완료")
    let createBtn = AuthBtn() // 나중에 이름 수정하기
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        workSpaceName.tf.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func configureView() {
        createBtn.text = "완료"
        view.endEditing(true)
        scrollView.endEditing(true)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true){ }
        }.disposed(by: disposeBag)
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    override func configureLayout() {
        self.addChild(profileVC)
        view.addSubview(scrollView)
        scrollView.addSubview(profileVC.view)
        scrollView.addSubview(stView)
        view.addSubview(createBtn)
    }
    override func configureNavigation() {
        navigationItem.title = "워크스페이스 생성"
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationController?.navigationBar.backgroundColor = .white
        self.isModalInPresentation = true
    }
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        profileVC.view.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).inset(24)
            make.width.height.equalTo(70)
            make.centerX.equalTo(scrollView.contentLayoutGuide)
        }
        stView.snp.makeConstraints { make in
            make.top.equalTo(profileVC.view.snp.bottom).inset(-16)
            make.bottom.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        createBtn.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
    }
}
