//
//  DMChatView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit
import SnapKit
import RxSwift
import ReactorKit

final class DMChatView:MessageView<DMChatReactor,DMCellItem,DMAsset>{
    var dataSource: DMDataSource!
    override func bind(reactor: DMChatReactor) {
        super.bind(reactor: reactor)
        naviBarBinding(reactor: reactor)
        textFieldBinding(reactor: reactor)
        configureCollectionView(reactor: reactor)
        reactor.action.onNext(.initChat)
    }
    
    override func configureView() {
        super.configureView()
    }
    override func configureLayout() {
        super.configureLayout()
    }
    override func configureNavigation() {
        super.configureNavigation()
        self.titleLabel.attributedText = titleTextStyle(fullText: reactor?.title ?? "")
        self.navigationItem.rightBarButtonItem = .init(systemItem: .action)
        self.navigationItem.rightBarButtonItem?.tintColor = .clear
    }
    override func configureConstraints() {
        super.configureConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}
