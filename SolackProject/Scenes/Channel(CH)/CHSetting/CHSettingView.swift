//
//  CHSettingView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CHSettingView: BaseVC{
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func configureView() {
        
    }
    override func configureLayout() {
        
    }
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = .getBackBtn
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.text = "채널 설정"
        self.navigationItem.titleView = label
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureConstraints() {
        
    }
}
