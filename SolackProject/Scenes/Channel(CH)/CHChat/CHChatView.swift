//
//  CHChatView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Combine
final class CHChatView: BaseVC,View{
    typealias ImageViewerItem = ChatFields.ChatTextField.ImageViewer.Item
    var disposeBag = DisposeBag()
    var subscription = Set<AnyCancellable>()
    func bind(reactor: CHChatReactor) {
        configureCollectionView(reactor: reactor)
        naviBarBinding(reactor: reactor)
        textFieldBinding(reactor: reactor)
        reactor.action.onNext(.initChat)
    }
    deinit{
        print("채널 뷰가 사라짐!!")
    }
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: DataSource!
    @MainActor let titleLabel = UILabel(frame: .init(x: 0, y: 0, width: 300, height: 300))
    let chatField = ChatFields(placeholder: "메시지를 입력하세요")
    var isShowKeyboard:CGFloat? = nil
    var showKeyboard:Bool = false
    var originHeight:CGFloat = 0
    var progressView = CHProgressView()
    @MainActor func updateTitleLabel(title:String,number:Int){
        
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
    override func configureNavigation() {
        Task{@MainActor in
//            self.navigationItem.title = reactor!.title
            self.navigationItem.titleView = titleLabel
            titleLabel.textAlignment = .center
            updateTitleLabel(title: reactor!.title, number: reactor!.currentState.memberCount)
        }
        self.navigationItem.leftBarButtonItem = .getBackBtn
        self.navigationItem.rightBarButtonItem = .init(image: .init(systemName: "list.bullet",withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17))))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationItem.rightBarButtonItem?.tintColor = .text
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            let vc = CHSettingView()
            //MARK: -- 서비스 Provider 추후에 수정
            vc.reactor = CHSettingReactor(owner.reactor!.provider,
                                          channelTitle: owner.reactor!.title,
                                          channelID: owner.reactor!.channelID)
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureLayout() {
        self.view.addSubview(collectionView)
        self.view.addSubview(chatField)
        view.addSubview(progressView)
    }
    override func configureConstraints() {
        chatField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalToSuperview().inset(30)
        }
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(chatField.snp.top).inset(-4)
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
    var prevHeight:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        progressView.isHidden = true
        chatField.needsUpdateCollectionViewLayout.bind(with: self) { owner, _ in
            Task{@MainActor in
                owner.chatField.layoutIfNeeded()
                try await Task.sleep(for: .seconds(0.1))
                await MainActor.run {
                    if owner.collectionView.isScrollable{
                        let height = owner.chatField.bounds.height - owner.prevHeight
                        owner.collectionView.scrollAppend(yAxis: height, animated: false)
                        owner.prevHeight = owner.chatField.bounds.height
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
}
extension UIBarButtonItem{
    static var getBackBtn: UIBarButtonItem{
        UIBarButtonItem(image: .init(systemName: "chevron.left",withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17))))
    }
}
//MARK: -- 키보드 설정
extension CHChatView{
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
    @objc func handleKeyboardShow(notification: Notification) {
        guard showKeyboard == false else {return}
        if let userInfo = notification.userInfo {
            if let keyboardFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
                let keyboardFrame = keyboardFrameValue.cgRectValue
                self.isShowKeyboard = keyboardFrame.size.height - 20
                self.chatField.snp.remakeConstraints { make in
                    make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(16)
                    make.bottom.equalToSuperview().inset(keyboardFrame.size.height + 12)
                }
                self.chatField.layoutIfNeeded()
                self.collectionView.snp.remakeConstraints { make in
                    make.top.horizontalEdges.equalToSuperview()
                    make.bottom.equalTo(self.chatField.snp.top).inset(-4)
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
    @objc func handleKeyboardHide(notification: Notification){
        guard showKeyboard == true else {return}
        let contentInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = contentInset
        collectionView.contentInset = contentInset
        UIView.animate(withDuration: 0.2) {
            self.chatField.snp.remakeConstraints { make in
                make.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(16)
                make.bottom.equalToSuperview().inset(30)
            }
            self.collectionView.snp.remakeConstraints { make in
                make.top.horizontalEdges.equalToSuperview()
                make.bottom.equalTo(self.chatField.snp.top).inset(-4)
            }
            self.chatField.layoutIfNeeded()
            self.collectionView.layoutIfNeeded()
        }
        showKeyboard.toggle()
    }
}
