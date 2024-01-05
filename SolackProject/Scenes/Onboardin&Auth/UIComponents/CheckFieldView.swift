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
final class CheckInputFieldView: UIStackView{
    var inputText: ControlProperty<String>!
    var isValidate: Bool = false{
        didSet{
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
        self.inputText = tf.rx.text.orEmpty
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
    }
    required init(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    func binding(){
        
    }
}
