//
//  ChatFields.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
final class ChatFields:UIView{
    typealias ImageViewerItem = ChatFields.ChatTextField.ImageViewer.Item
    let isActiveSend:BehaviorSubject<Bool> = .init(value: false)
    
    let text:PublishSubject<String> = .init()
    var send: ControlEvent<Void>!
    var addImages: ControlEvent<Void>!
    weak var imageFiles: PublishSubject<[ImageViewerItem]>!
    weak var deleteImageItem: PublishSubject<String>!
    weak var needsUpdateCollectionViewLayout:PublishSubject<()>!
    let placeholder:String
    var hiddenImageView:Bool = false{
        didSet{
            self.chatField.hiddenImageView = hiddenImageView
        }
    }
    private var chatField = ChatTextField()
    private var disposeBag = DisposeBag()
    private let sendBtn = {
        let btn = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = .send
        configuration.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        btn.configuration = configuration
        return btn
    }()
    let addItemBtn = {
        let btn = UIButton()
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "plus" ,withConfiguration: UIImage.SymbolConfiguration(font: FontType.body.get()))
        configuration.baseForegroundColor = .secondary
        configuration.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        btn.configuration = configuration
        return btn
    }()
    init(placeholder:String){
        self.placeholder = placeholder
        super.init(frame: .zero)
        configureView()
        chatField.placeholder = placeholder
        chatField.textPassthrough.bind(to: text).disposed(by: disposeBag)
        self.send = sendBtn.rx.tap
        self.addImages = addItemBtn.rx.tap
        self.imageFiles = chatField.imageFiles
        self.deleteImageItem = chatField.imageVierwer.deleteItemID
        self.needsUpdateCollectionViewLayout = chatField.needsUpdateCollectionViewLayout
        self.send.bind(with: self) { owner, _ in
            if owner.chatField.textField.textColor == .text{
                owner.chatField.textField.text = ""
            }
        }.disposed(by: disposeBag)
        self.isActiveSend.distinctUntilChanged()
            .bind(with: self) { owner, value in
                Task{@MainActor in
                    if value{
                        owner.sendBtn.configuration?.image = .sendActive
                        owner.sendBtn.isUserInteractionEnabled = true
                    }else{
                        owner.sendBtn.configuration?.image = .send
                        owner.sendBtn.isUserInteractionEnabled = false
                    }
                }
        }.disposed(by: disposeBag)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    func configureView(){
        addSubview(addItemBtn)
        addSubview(chatField)
        addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.trailing.equalTo(self).inset(12)
            make.bottom.equalTo(self).inset(8)
            make.width.height.equalTo(24)
        }
        addItemBtn.snp.makeConstraints { make in
            make.leading.equalTo(self).inset(8)
            make.bottom.equalTo(self).inset(8)
            make.width.height.equalTo(24)
        }
        chatField.snp.makeConstraints { make in
            make.verticalEdges.equalTo(self).inset(4)
            make.leading.equalTo(addItemBtn.snp.trailing).inset(-4)
            make.trailing.equalTo(sendBtn.snp.leading).inset(-4)
        }
        backgroundColor = .gray1
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .circular
    }
}
extension ChatFields{
    final class ChatTextField: UIStackView,UITextViewDelegate{
        typealias ImageViewerItem = ChatFields.ChatTextField.ImageViewer.Item
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
        var imageFiles: PublishSubject<[ImageViewerItem]>!
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
