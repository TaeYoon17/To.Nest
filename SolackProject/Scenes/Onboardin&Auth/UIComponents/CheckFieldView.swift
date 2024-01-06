//
//  CheckFieldView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/5/24.
//
/*
 사용 가능하지 않은 경우 gray3로 통일
 */
import SnapKit
import RxCocoa
import RxSwift
import UIKit
protocol AuthFieldAble{
    var accAction: ControlEvent<Void>! {get set}
    var validFailed:BehaviorSubject<Bool> {get set}
    var authValid:BehaviorSubject<Bool> {get set}
    func setAccessory(_ accessoryText:String?)
}
final class CheckInputFieldView: UIStackView,AuthFieldAble{
    var inputText: ControlProperty<String>!
    lazy var accAction: ControlEvent<Void>! = btn.rx.tap
    var validFailed:BehaviorSubject<Bool> = .init(value: false)
    var authValid: BehaviorSubject<Bool> = .init(value: false)
    var isValidate: Bool = false{
        didSet{
            self.validataion.isUserInteractionEnabled = isValidate
            let config = validataion.config.cornerRadius(8).foregroundColor(.white).text("중복 확인", font: .title2)
            if isValidate{
                config.backgroundColor(.accent).apply()
            }else{
                config.backgroundColor(.gray3).apply()
            }
        }
    }
    
    let tf:UITextField = .init()
    let validataion: UIButton = .init()
    private let label: UILabel = .init()
    private let btn = AuthBtn()
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
    
    private var disposeBag = DisposeBag()
    private lazy var accessoryView: UIView = {
        return UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 70))
    }()
    init(field:String,placeholder:String,keyType:UIKeyboardType = .default,accessoryText:String? = nil){
        super.init(frame: .zero)
        self.inputText = tf.rx.text.orEmpty
        self.tf.keyboardType = keyType
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
        config.backgroundColor(.gray3).apply()
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
        setAccessory(accessoryText)
        binding()
    }
    required init(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    func binding(){
        validFailed.bind(with: self) { owner, value in
            print(value)
            self.label.textColor = !value ? .text : .error
        }.disposed(by: disposeBag)
    }
    func setAccessory(_ accessoryText:String?){
        if let accessoryText{
            let width = UIScreen.main.bounds.width - 48
            tf.inputAccessoryView = accessoryView
            accessoryView.addSubview(btn)
            accessoryView.backgroundColor = .gray1
            btn.text = accessoryText
            btn.snp.makeConstraints { make in
                make.height.equalTo(44)
                make.bottom.equalToSuperview().inset(12)
                make.width.equalToSuperview().inset(24)
                make.centerX.equalToSuperview()
            }
            authValid.subscribe(with: self){ owner,val in
                owner.btn.isAvailable = val
            }.disposed(by: disposeBag)
        }
    }
}
