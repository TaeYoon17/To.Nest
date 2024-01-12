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
import ReactorKit
import Toast
final class SignInEmailView: BaseVC,View{
    var disposeBag = DisposeBag()
    typealias A = EmailSignInReactor.Action
    func bind(reactor: EmailSignInReactor) {
        let fields = [emailField,pwField]
        func actionBinding(_ action : Observable<A>){ action.bind(to: reactor.action).disposed(by: disposeBag) }
        actionBinding(emailField.inputText.map{A.setEmail($0)})
        actionBinding(pwField.inputText.map{A.setPassword($0)})
        actionBinding(signInBtn.rx.tap.map{A.signIn})
        fields.forEach { (field:AuthFieldAble) in
            actionBinding(field.accAction.map{A.signIn})
        }
        
        reactor.state.map{$0.email}.bind(to: emailField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.password}.bind(to: pwField.inputText).disposed(by: disposeBag)
        // 에러 및 실패시 
        fieldErrorBinding(reactor)
        // 로그인 버튼 Interactive
        reactor.state.map{$0.signAvailable}.bind(with: self) { owner, val in
            owner.signInBtn.isAvailable = val
        }.disposed(by: disposeBag)
        fields.forEach { (field:AuthFieldAble) in
            reactor.state.map{$0.signAvailable}.bind(to: field.authValid).disposed(by: disposeBag)
        }
        reactor.state.map{$0.toastMessage}.bind(with: self) { owner, type in
            guard let type else {return}
            owner.toastUp(type: type)
        }.disposed(by: disposeBag)
    }
    func fieldErrorBinding(_ reactor: EmailSignInReactor){
        reactor.state.map{$0.erroredEmail}.bind(to: emailField.validFailed).disposed(by: disposeBag)
        reactor.state.map{$0.erroredPW}.bind(to: pwField.validFailed).disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    
    }
    //MARK: -- 뷰 구성
    let scrollView = UIScrollView()
    let emailField = InputFieldView(field: "이메일", placeholder: "이메일을 입력하세요",keyType: .emailAddress,accessoryText: "로그인")
    let pwField = InputFieldView(field: "비밀번호", placeholder: "비밀번호를 입력하세요",accessoryText: "로그인")
    let signInBtn = AuthBtn()
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
        signInBtn.text = "로그인"
        view.endEditing(true)
        scrollView.endEditing(true)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
        emailField.tf.autocapitalizationType = .none
        pwField.tf.isSecureTextEntry = true
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
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

extension SignInEmailView{
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
extension SignInEmailView:Toastable{
    func toastUp(type: ToastType){
        var style = ToastStyle()
        style.messageFont = FontType.body.get()
        style.cornerRadius = 8
        style.messageColor = .white
        style.verticalPadding = 9
        style.horizontalPadding = 16
        style.backgroundColor = type.getColor
        let toast = try! navigationController!.view.toastViewForMessage(type.contents, title: nil, image: nil, style: style)
        let radiusHeight = toast.frame.height / 2
        let minY = if let isShowKeyboard{
            isShowKeyboard - 70 - radiusHeight
        }else{
            signInBtn.frame.minY - 16 - radiusHeight
        }
        navigationController?.view.showToast(toast, duration: ToastManager.shared.duration,point: .init(x: signInBtn.frame.midX, y: minY),completion: nil)
    }
}
extension EmailSignInToastType{
    var getColor:UIColor{
        switch self{
        case .emailValidataionError,.other,.others,.pwCondition,.signInFailed:
                .error
        }
    }
}
