//
//  MSGTextField.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
extension MSGField{
    final class MSGTextField: UIStackView,UITextViewDelegate{
        var hiddenImageView:Bool = false{
            didSet{
                needsUpdateCollectionViewLayout.onNext(())
                Task{ @MainActor in
                    self.imageVierwer.isHidden = hiddenImageView
                    
                }
            }
        }
        var disposeBag = DisposeBag()
        let textPassthrough = PublishSubject<String>()
        var imageFiles: PublishSubject<[MSGImageViewerItem]>!
        var needsUpdateCollectionViewLayout = PublishSubject<()>()
        
        var placeholder = ""{
            didSet{
                textField.text = placeholder
                textField.textColor = .secondary
            }
        }
        var prevHeight:CGFloat = 0
        let textHeight:CGFloat = {
            let label = UILabel()
            label.text = "asd"
            label.font = FontType.body.get()
            return label.intrinsicContentSize.height + 2
        }()
        var nowHeight:CGFloat = 0
        let textField = {
            let field = UITextView()
            field.font = FontType.body.get()
            field.textAlignment = .left
            return field
        }()
        let imageVierwer = ImageViewer()
        init(){
            super.init(frame: .zero)
            self.axis = .vertical
            addArrangedSubview(textField)
            addArrangedSubview(imageVierwer)
            textField.isScrollEnabled = false
            self.distribution = .fill
            self.alignment = .fill
            self.nowHeight = textHeight
            textField.snp.makeConstraints { make in
                make.height.lessThanOrEqualTo(textHeight * 3 + 4)
            }
            imageVierwer.snp.makeConstraints { make in
                make.height.equalTo(52)
            }
            self.textField.delegate = self
            backgroundColor = .gray2
            textField.backgroundColor = .gray1
            textField.text = "a"
            textField.text = placeholder
            textPassthrough.bind(with: self) { owner, text in
                owner.textField.text = text
            }.disposed(by: disposeBag)
            self.imageFiles = imageVierwer.updatedFileDatas
            self.hiddenImageView = true
        }
        required init(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
    }
}
