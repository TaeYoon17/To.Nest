//
//  InputFieldView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/5/24.
//

import SnapKit
import RxCocoa
import RxSwift
import UIKit
final class InputFieldView: UIStackView,AuthFieldAble{
    var inputText: ControlProperty<String>!
    lazy var accAction: ControlEvent<Void>! = btn.rx.tap
    var validFailed: RxSwift.BehaviorSubject<Bool> = .init(value: false)
    var authValid: BehaviorSubject<Bool> = .init(value: false)
    let tf:UITextField = .init()
    private let btn = AuthBtn()
    private let label: UILabel = .init()
    private var disposeBag = DisposeBag()
    private lazy var accessoryView: UIView = {
        return UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 70))
    }()
    init(field:String,placeholder:String,keyType:UIKeyboardType = .default,accessoryText:String? = nil){
        super.init(frame: .zero)
        self.inputText =  self.tf.rx.text.orEmpty
        
        self.tf.keyboardType = keyType
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
        let labelAttr = field.attr(type: .title2)
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
        self.validFailed.bind(with: self) { owner, value in
            owner.label.textColor = !value ? .text : .error
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

