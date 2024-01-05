//
//  SignUpView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//
import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import Toast
final class SignUpView:BaseVC,View{
    var disposeBag: DisposeBag = .init()
    typealias A = SignUpViewReactor.Action
    func bind(reactor: SignUpViewReactor) {
        //MARK: -- Action Binding
        func actionBinding(_ action : Observable<A>){ action.bind(to: reactor.action).disposed(by: disposeBag) }
        actionBinding(emailField.inputText.map{A.setEmail($0)})
        actionBinding(emailField.validataion.rx.tap.map{A.dobuleCheck})
        actionBinding(nicknameField.inputText.map{A.setNickname($0)})
        actionBinding(contactField.inputText.map{A.setPhone($0)})
        actionBinding(pwField.inputText.map{A.setSecret($0)})
        actionBinding(checkPW.inputText.map{A.setCheckSecret($0)})
        
        //MARK: -- State Binding
        reactor.state.map{$0.email}.distinctUntilChanged().bind(to: emailField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.nickName}.distinctUntilChanged().bind(to: nicknameField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.phone}.distinctUntilChanged().bind(to: contactField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.secret}.distinctUntilChanged().bind(to: pwField.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.checkSecret}.distinctUntilChanged().bind(to: checkPW.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.signUpToast}.distinctUntilChanged().bind(with: self) { owner, type in
            guard let type else {return}
            owner.toastUp(type: type)
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isEmailChecked}.distinctUntilChanged().bind(with: self) { owner, value in
            owner.emailField.isValidate = value
            owner.isSignUpBtnAvailable(value)
        }.disposed(by: disposeBag)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray1
    }
    let scrollView = UIScrollView()
    let signUpBtn = UIButton()
    let emailField = CheckInputFieldView(field: "이메일", placeholder: "이메일을 입력하세요")
    let nicknameField = InputFieldView(field: "닉네임", placeholder: "닉네임을 입력하세요")
    let contactField = InputFieldView(field: "연락처", placeholder: "전화번호를 입력하세요")
    let pwField = InputFieldView(field: "비밀번호", placeholder: "비밀번호를 입력하세요")
    let checkPW = InputFieldView(field: "비밀번호 확인", placeholder: "비밀번호를 한 번 더 입력하세요")
    lazy var stView = {
        let subViews = [emailField,nicknameField,contactField,pwField,checkPW]
        let st = UIStackView(arrangedSubviews: subViews)
        st.axis = .vertical
        st.spacing = 24
        st.distribution = .fill
        st.alignment = .fill
        return st
    }()
    override func configureView() {
//        scrollView.keyboardDismissMode = .interactive
        scrollView.keyboardDismissMode = .onDragWithAccessory
        view.endEditing(true)
        scrollView.endEditing(true)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
    }
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
    }
    override func configureLayout() {
        view.addSubview(scrollView)
        view.addSubview(signUpBtn)
        scrollView.addSubview(stView)
    }
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.isModalInPresentation = true
        self.navigationItem.title = "회원가입"
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true){
                //                owner.reactor?.provider.authService.navigation.onNext(.dismissCompleted)
            }
        }.disposed(by: disposeBag)
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
        signUpBtn.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalToSuperview().inset(45)
            make.height.equalTo(44)
        }
    }
}
extension SignUpView{
    func toastUp(type: SignUpToastType){
        var style = ToastStyle()
        style.messageFont = FontType.body.get()
        style.cornerRadius = 8
        style.messageColor = .white
        style.verticalPadding = 9
        style.horizontalPadding = 16
        switch type{
        case .alreadyAvailable,.vailableEmail:
            style.backgroundColor = .accent
        case .emailValidataionError:
            style.backgroundColor = .gray3
        }
        let toast = try! navigationController!.view.toastViewForMessage(type.contents, title: nil, image: nil, style: style)
        let radiusHeight = toast.frame.height / 2
        navigationController?.view.showToast(toast, duration: ToastManager.shared.duration,point: .init(x: signUpBtn.frame.midX, y: signUpBtn.frame.minY - 16 - radiusHeight),completion: nil)
    }
    func isSignUpBtnAvailable(_ val: Bool){
        let config = signUpBtn.config.foregroundColor(.white).cornerRadius(8).text("회원가입", font: .title2)
        if val{
            config.backgroundColor(.accent).apply()
            
        }else{
            config.backgroundColor(.gray3).apply()
            signUpBtn.isUserInteractionEnabled = val
        }
    }
}


