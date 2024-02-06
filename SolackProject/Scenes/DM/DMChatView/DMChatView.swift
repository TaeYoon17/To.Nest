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
    override func bind(reactor: DMChatReactor) {
        
    }
    override func configureView() {
        super.configureView()
    }
    override func configureLayout() {
        super.configureLayout()
    }
    override func configureNavigation() {
        super.configureNavigation()
        self.titleLabel.attributedText = titleTextStyle(fullText: "안녕하세요")
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
