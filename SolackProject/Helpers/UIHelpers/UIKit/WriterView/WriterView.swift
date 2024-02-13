//
//  WriterView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/15/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import Toast

class WriterView<Fail:FailedProtocol,Toast:ToastType,T: WriterReactor<Fail,Toast>>: BaseVC,View,Toastable,WritableView{
    func apply(config: WriterConfigureation) {
        var config = config
        pwField.apply(config.descriptionField)
        emailField.apply(config.mainField)
        navigationItem.title = config.navigationTitle
        actionBtn.text = config.buttonText
        self.isModalInPresentation = !config.isAvaileScrollClose
    }
    typealias GenericWriterReactor = WriterReactor<Fail,Toast>
    var disposeBag = DisposeBag()
    typealias A = GenericWriterReactor.Action
    var writerConfig:WriterConfigureation
    init(config: WriterConfigureation,reactor:T){
        self.writerConfig = config
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
//        self.apply(config: writerConfig)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    func bind(reactor: T) {
        print(reactor.initialState)
        let fields = [emailField,pwField]
        func actionBinding(_ action : Observable<A>){
            action.bind(to: reactor.action).disposed(by: disposeBag)
        }
        emailField.inputText.map{T.Action.setName($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        actionBinding(emailField.inputText.map{A.setName($0)})
        actionBinding(pwField.inputText.map{A.setDescription($0)})
        actionBinding(actionBtn.rx.tap.map{A.confirmAction})
        fields.forEach { (field:AuthFieldAble) in
            actionBinding(field.accAction.map{A.confirmAction})
        }
        
        reactor.state.map{$0.name}.bind(to: emailField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.description}.bind(to: pwField.inputText).disposed(by: disposeBag)
        // 에러 및 실패시
        fieldErrorBinding(reactor)
        // 로그인 버튼 Interactive
        reactor.state.map{$0.isCreatable}.bind(with: self) { owner, val in
            owner.actionBtn.isAvailable = val
        }.disposed(by: disposeBag)
        fields.forEach { (field:AuthFieldAble) in
            reactor.state.map{$0.isCreatable}.bind(to: field.authValid).disposed(by: disposeBag)
        }
        reactor.state.map{$0.toast}.bind(with: self) { owner, type in
            guard let type else {return}
//            owner.toastUp(type: type)
            owner.toastUp(type: type)
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isClose}.subscribe(on: MainScheduler.instance).bind(with: self) { owner, isClose in
            if isClose{
                Task{@MainActor in
                    owner.dismiss(animated: true)
                }
            }
        }.disposed(by: disposeBag)
    }
    func fieldErrorBinding(_ reactor: GenericWriterReactor){
        reactor.state.map{$0.erroredName}.bind(to: emailField.validFailed).disposed(by: disposeBag)
        reactor.state.map{$0.erroredDescription}.bind(to: pwField.validFailed).disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
        apply(config: self.writerConfig)
    }
    //MARK: -- 뷰 구성
    let scrollView = UIScrollView()
    lazy var emailField = InputFieldView(field: writerConfig.mainField.field, placeholder: writerConfig.mainField.placeholder,keyType: writerConfig.mainField.keyType,accessoryText: writerConfig.mainField.accessoryText)
    lazy var pwField = InputFieldView(field: writerConfig.descriptionField.field, placeholder: writerConfig.descriptionField.placeholder,keyType: writerConfig.descriptionField.keyType,accessoryText: writerConfig.descriptionField.accessoryText)
    let actionBtn = AuthBtn()
    var isShowKeyboard :CGFloat? = nil
    lazy var stView = {
        let subViews = [emailField,pwField]
        let st = UIStackView(arrangedSubviews: subViews)
        st.axis = .vertical
        st.distribution = .fill
        st.alignment = .fill
        return st
    }()
    override func configureView() {
        actionBtn.text = writerConfig.buttonText
        view.endEditing(true)
        scrollView.endEditing(true)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    override func configureLayout() {
        [scrollView,actionBtn].forEach{view.addSubview($0)}
        scrollView.addSubview(stView)
    }
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.isModalInPresentation = true
        self.navigationItem.title = writerConfig.navigationTitle
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
        actionBtn.snp.makeConstraints  { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
    }
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
//        print("Keyboard will Hide")
        self.isShowKeyboard = nil
        let contentInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.scrollIndicatorInsets = contentInset
        scrollView.contentInset = contentInset
    }
    var toastY: CGFloat {
        if let isShowKeyboard{
            isShowKeyboard - 70 - toastHeight / 2
        }else{
            actionBtn.frame.minY - 16 - toastHeight / 2
        }
    }
    
    var toastHeight: CGFloat = 0
    
}
