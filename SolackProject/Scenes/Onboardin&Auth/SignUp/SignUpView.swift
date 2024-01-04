//
//  SignUpView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//
import UIKit
import SnapKit
import ReactorKit
final class SignUpView:BaseVC,View{
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
    var disposeBag: DisposeBag = .init()
    func bind(reactor: SignUpViewReactor) {
        reactor.state.map{$0.isSignUpAble}.subscribe(with: self){ owner,val in
            let config = owner.signUpBtn.config.foregroundColor(.white).cornerRadius(8).text("가입하기", font: .title2)
            config.backgroundColor(val ? .accent : .gray3).apply()
        }.disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray1
    }
    
    override func configureView() {
        
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

final class InputFieldView: UIStackView{
    let tf:UITextField = .init()
    private let label: UILabel = .init()
    init(field:String,placeholder:String){
        super.init(frame: .zero)
        [label,tf].forEach { addArrangedSubview($0) }
        self.axis = .vertical
        self.distribution = .fillProportionally
        self.alignment = .fill
        label.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        tf.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(44)
        }
        //            self.backgroundColor = .blue/
        let labelAttr = field.attr(type: .title2)
        //            label.attributedText = NSAttributedString(labelAttr)
        label.text = field
        label.font = FontType.title2.get()
        tf.placeholder = placeholder
        tf.backgroundColor = .white
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8
        tf.leftView = .init(frame: .init(x: 0, y: 0, width: 12, height: 44))
        tf.leftViewMode = .always
        var attr = placeholder.attr(type: .body)
        attr.foregroundColor = .secondary
        tf.attributedPlaceholder = NSAttributedString(attr)
        tf.font = FontType.body.get()
    }
    required init(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
final class CheckInputFieldView: UIStackView{
    let tf:UITextField = .init()
    let validataion: UIButton = .init()
    private let label: UILabel = .init()
    private lazy var fieldView = {
        let v = UIView()
        v.addSubview(tf)
        v.addSubview(validataion)
        validataion.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.verticalEdges.trailing.equalToSuperview()
        }
        tf.snp.makeConstraints { make in
            make.verticalEdges.leading.equalToSuperview()
            make.trailing.equalTo(validataion.snp.leading).inset(-12)
        }
        return v
    }()
    init(field:String,placeholder:String){
        super.init(frame: .zero)
        [label,fieldView].forEach { addArrangedSubview($0) }
        self.axis = .vertical
        self.distribution = .fillProportionally
        self.alignment = .fill
        spacing = 4
        label.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        fieldView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(44)
        }
        var config = validataion.config.cornerRadius(8).foregroundColor(.white).text("중복 확인", font: .title2)
        config.backgroundColor(.accent).apply()
        label.text = field
        label.font = FontType.title2.get()
        tf.placeholder = placeholder
        tf.backgroundColor = .white
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8
        tf.leftView = .init(frame: .init(x: 0, y: 0, width: 12, height: 44))
        tf.leftViewMode = .always
        var attr = placeholder.attr(type: .body)
        attr.foregroundColor = .secondary
        tf.attributedPlaceholder = NSAttributedString(attr)
        tf.font = FontType.body.get()
    }
    required init(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    func binding(){
        
    }
}

