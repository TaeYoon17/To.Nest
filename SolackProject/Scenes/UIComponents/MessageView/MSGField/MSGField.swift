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
final class MSGField:UIView{
    let isActiveSend:BehaviorSubject<Bool> = .init(value: false)
    let text:PublishSubject<String> = .init()
    var send: ControlEvent<Void>!
    var addImages: ControlEvent<Void>!
    weak var imageFiles: PublishSubject<[MSGImageViewerItem]>!
    weak var deleteImageItem: PublishSubject<String>!
    weak var needsUpdateCollectionViewLayout:PublishSubject<()>!
    let placeholder:String
    var hiddenImageView:Bool = false{
        didSet{
            self.textField.hiddenImageView = hiddenImageView
        }
    }
    private var textField = MSGTextField()
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
        textField.placeholder = placeholder
        textField.textPassthrough.bind(to: text).disposed(by: disposeBag)
        self.send = sendBtn.rx.tap
        self.addImages = addItemBtn.rx.tap
        self.imageFiles = textField.imageFiles
        self.deleteImageItem = textField.imageVierwer.deleteItemID
        self.needsUpdateCollectionViewLayout = textField.needsUpdateCollectionViewLayout
        self.send.bind(with: self) { owner, _ in
            if owner.textField.textField.textColor == .text{
                owner.textField.textField.text = ""
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
        addSubview(textField)
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
        textField.snp.makeConstraints { make in
            make.verticalEdges.equalTo(self).inset(4)
            make.leading.equalTo(addItemBtn.snp.trailing).inset(-4)
            make.trailing.equalTo(sendBtn.snp.leading).inset(-4)
        }
        backgroundColor = .gray1
        self.layer.cornerRadius = 8
        self.layer.cornerCurve = .circular
    }
}

