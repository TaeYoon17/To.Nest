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
final class InputFieldView: UIStackView{
    var inputText: ControlProperty<String>!
    let tf:UITextField = .init()
    private let label: UILabel = .init()
    
    lazy var accessoryView: UIView = {
        return UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 70))
    }()
    init(field:String,placeholder:String){
        super.init(frame: .zero)
        self.inputText =  self.tf.rx.text.orEmpty
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
        let width = UIScreen.main.bounds.width - 48
        print(width)
        tf.inputAccessoryView = accessoryView
        let btn = SignUpBtn()
        accessoryView.addSubview(btn)
        accessoryView.backgroundColor = .gray1
        btn.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(12)
            make.width.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
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
    }
    required init(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
final class SignUpBtn: UIButton{
    var isAvailable: Bool = false{
        didSet{
            var con = config.cornerRadius(10).foregroundColor(.white).text("회원가입", font: .title2)
            con.backgroundColor(isAvailable ? .accent : .gray3).apply()
            self.isUserInteractionEnabled = isAvailable
        }
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    init() {
        super.init(frame: .zero)
        var con = config.cornerRadius(10).foregroundColor(.white).text("회원가입", font: .title2)
        con.backgroundColor(isAvailable ? .accent : .gray3).apply()
        self.isUserInteractionEnabled = false
    }
}
