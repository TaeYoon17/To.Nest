//
//  CHInviteView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/15/24.
//

import SnapKit
import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import Toast
final class WSInviteView: BaseVC,View,Toastable{
    var disposeBag = DisposeBag()
    func bind(reactor: WSInviteReactor) {
        field.inputText.map{WSInviteReactor.Action.setEmail($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        actionBtn.rx.tap.map{WSInviteReactor.Action.inviteAction}.bind(to: reactor.action).disposed(by: disposeBag)
        field.accAction.map{WSInviteReactor.Action.inviteAction}.bind(to: reactor.action).disposed(by: disposeBag)
        reactor.state.map{$0.isInvitable}.distinctUntilChanged().subscribe(on: MainScheduler.asyncInstance).bind(to: field.authValid).disposed(by: disposeBag)
        reactor.state.map{$0.isInvitable}.distinctUntilChanged().subscribe(on: MainScheduler.asyncInstance).bind(with: self) { owner, value in
            owner.actionBtn.isAvailable = value
        }.disposed(by: disposeBag)
        reactor.state.map{$0.toast}.delay(.microseconds(100), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, type in
            guard let type else {return}
            owner.toastUp(type: type)
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isClose}.delay(.microseconds(100), scheduler: MainScheduler.instance).bind(with: self) { owner, value in
            if value{
                owner.dismiss(animated: true)
            }
        }.disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    }
    let field = InputFieldView(field: "이메일", placeholder: "초대하려는 팀원의 이메일을 입력하세요.",keyType: .emailAddress,accessoryText: "초대 보내기")
    let actionBtn = AuthBtn()
    var isShowKeyboard: CGFloat? = nil
    let scrollView = UIScrollView()
    override func configureNavigation() {
        navigationItem.title = "팀원 초대"
        navigationController?.fullSheetSetting()
        navigationItem.leftBarButtonItem = .init(image:UIImage(systemName: "xmark"))
        navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationController?.isModalInPresentation = true
    }
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        field.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).inset(24)
            make.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        actionBtn.snp.makeConstraints  { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
    }
    override func configureView() {
        actionBtn.text = "초대 보내기"
        view.endEditing(true)
        scrollView.endEditing(true)
    }
    override func configureLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(field)
        self.view.addSubview(actionBtn)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
        field.tf.autocapitalizationType = .none
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    //MARK: -- 토스트 타입 설정
    var toastY: CGFloat{
        if let isShowKeyboard{
            isShowKeyboard - 70 - toastHeight / 2
        }else{
            actionBtn.frame.minY - 16 - toastHeight / 2
        }
    }
    var toastHeight: CGFloat = 0
}
extension WSInviteView{
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func handleKeyboardShow(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
                let keyboardFrame = keyboardFrameValue.cgRectValue
                //                print(keyboardFrame)
                self.isShowKeyboard = keyboardFrame.minY
                let contentInset = UIEdgeInsets(
                    top: 0.0,
                    left: 0.0,
                    bottom: keyboardFrame.size.height,
                    right: 0.0)
                scrollView.contentInset = contentInset
                scrollView.scrollIndicatorInsets = contentInset
            }
        }
    }
    @objc func handleKeyboardHide(notification: Notification){
        print("Keyboard will Hide")
        self.isShowKeyboard = nil
        let contentInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = contentInset
        scrollView.contentInset = contentInset
    }
}
