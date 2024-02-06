//
//  MsgView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//
import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Combine
class MessageView<MessageReactor:Reactor,CellItem:MessageCellItem,CellAsset:MessageAsset>:BaseVC,View{
    var disposeBag: DisposeBag = .init()
    var subscription = Set<AnyCancellable>()
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    @MainActor let titleLabel = UILabel(frame: .init(x: 0, y: 0, width: 300, height: 300))
    var dataSource: MessageDataSource<MessageReactor, CellItem, CellAsset>!
    let msgField = MSGField(placeholder: "메시지를 입력하세요")
    var isShowKeyboard:CGFloat? = nil
    var showKeyboard:Bool = false
    var originHeight:CGFloat = 0
    var progressView = ProgressVC.ProgressView()
    func updateTitleLabel(title:String,number:Int = 0){
        let fullText = if number <= 0{ "#\(title)" } else { "#\(title) \(number)" }
        let attributedString = NSMutableAttributedString(string: fullText,attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.text
        ])
        if number > 0{
            let range = (fullText as NSString).range(of: " \(number)")
            attributedString.addAttribute(.foregroundColor, value: UIColor.secondary, range: range)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.titleLabel.attributedText = attributedString
        }
    }
    func bind(reactor: MessageReactor) { }
    override func configureNavigation() {
        Task{@MainActor in
            self.navigationItem.titleView = titleLabel
            titleLabel.textAlignment = .center
        }
        self.navigationItem.leftBarButtonItem = .getBackBtn
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func configureLayout() {
        self.view.addSubview(collectionView)
        self.view.addSubview(msgField)
        view.addSubview(progressView)
    }
    override func configureConstraints() {
        msgField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalToSuperview().inset(30)
        }
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(msgField.snp.top).inset(-4)
        }
        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func configureView() {
        view.endEditing(true)
        collectionView.endEditing(true)
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
        progressView.placeholder = "이미지를 로딩 중입니다."
    }
    @objc func dismissMyKeyboard(){
        collectionView.endEditing(true)
        view.endEditing(true)
    }
    private var prevHeight:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        progressView.isHidden = true
        msgField.needsUpdateCollectionViewLayout.bind(with: self) { owner, _ in
            Task{@MainActor in
                owner.msgField.layoutIfNeeded()
                try await Task.sleep(for: .seconds(0.1))
                await MainActor.run {
                    if owner.collectionView.isScrollable{
                        let height = owner.msgField.bounds.height - owner.prevHeight
                        owner.collectionView.scrollAppend(yAxis: height, animated: false)
                        owner.prevHeight = owner.msgField.bounds.height
                    }
                }
            }
        }.disposed(by: disposeBag)
        self.msgField.hiddenImageView = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    //MARK: -- 키보드 설정
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.originHeight = view.frame.origin.y
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
    @objc private func handleKeyboardShow(notification: Notification) {
        guard showKeyboard == false else {return}
        if let userInfo = notification.userInfo {
            if let keyboardFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
                let keyboardFrame = keyboardFrameValue.cgRectValue
                self.isShowKeyboard = keyboardFrame.size.height - 20
                self.msgField.snp.remakeConstraints { make in
                    make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(16)
                    make.bottom.equalToSuperview().inset(keyboardFrame.size.height + 12)
                }
                self.msgField.layoutIfNeeded()
                self.collectionView.snp.remakeConstraints { make in
                    make.top.horizontalEdges.equalToSuperview()
                    make.bottom.equalTo(self.msgField.snp.top).inset(-4)
                }
                self.collectionView.layoutIfNeeded()
                Task{@MainActor in
                    if self.collectionView.isScrollable{
                        try await Task.sleep(for: .seconds(0.1))
                        self.collectionView.scrollAppend(yAxis: keyboardFrame.size.height,animated: true)
                    }
                }
            }
        }
        showKeyboard.toggle()
    }
    @objc private func handleKeyboardHide(notification: Notification){
        guard showKeyboard == true else {return}
        let contentInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = contentInset
        collectionView.contentInset = contentInset
        UIView.animate(withDuration: 0.2) {
            self.msgField.snp.remakeConstraints { make in
                make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(16)
                make.bottom.equalToSuperview().inset(30)
            }
            self.collectionView.snp.remakeConstraints { make in
                make.top.horizontalEdges.equalToSuperview()
                make.bottom.equalTo(self.msgField.snp.top).inset(-4)
            }
            self.msgField.layoutIfNeeded()
            self.collectionView.layoutIfNeeded()
        }
        showKeyboard.toggle()
    }
}

extension MessageView{
    func titleTextStyle(fullText:String)-> NSMutableAttributedString{
        NSMutableAttributedString(string: fullText,attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.text
        ])
    }
}
