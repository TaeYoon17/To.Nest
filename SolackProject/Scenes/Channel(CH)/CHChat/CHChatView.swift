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
        naviBarBinding(reactor: reactor)
        textFieldBinding(reactor: reactor)
        reactor.action.onNext(.initChat)
    }
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: DataSource!
    @MainActor let titleLabel = UILabel()
    let chatField = ChatFields(placeholder: "메시지를 입력하세요")
    var isShowKeyboard:CGFloat? = nil
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
        DispatchQueue.main.async {
            self.titleLabel.attributedText = attributedString
        }
    }
    override func configureNavigation() {
        self.navigationItem.titleView = titleLabel
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
            vc.reactor = CHSettingReactor(AppManager.shared.provider)
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureLayout() {
        self.view.addSubview(collectionView)
        self.view.addSubview(chatField)
        view.addSubview(progressView)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(chatField.snp.top).inset(8)
        }
        chatField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalToSuperview().inset(30)
        }
        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func configureView() {
        configureCollectionView()
        view.endEditing(true)
        collectionView.endEditing(true)
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.dismissMyKeyboard)))
        progressView.placeholder = "이미지를 로딩 중입니다."
    }
    @objc func dismissMyKeyboard(){
        collectionView.endEditing(true)
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        progressView.isHidden = true
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
        
        if let userInfo = notification.userInfo {
            if let keyboardFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) {
                let keyboardFrame = keyboardFrameValue.cgRectValue
                self.isShowKeyboard = keyboardFrame.size.height - 20
                self.view.frame.origin.y = -isShowKeyboard!
            }
        }
    }
    @objc func handleKeyboardHide(notification: Notification){
        self.view.frame.origin.y = 0
        self.isShowKeyboard = nil
        let contentInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = contentInset
        collectionView.contentInset = contentInset
    }
}
