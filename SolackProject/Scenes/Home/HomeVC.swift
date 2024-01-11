//
//  HomeVC.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
final class HomeVC: BaseVC{
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let navBar = NaviBar()
    let vm = HomeVM()
    var dataSource: HomeDataSource!
    let newMessageBtn = NewMessageBtn()
    var disposeBag = DisposeBag()
    lazy var sideVC = SideVC()
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar.workSpaceTap.bind(with: self) { owner, _ in
            // 슬라이드 뷰 구현 with swiftui
            var sideVC = SideVC()
            sideVC.modalPresentationStyle = .overFullScreen
            sideVC.isOpen = true
            owner.present(sideVC, animated: false)
        }.disposed(by: disposeBag)
    }
    override func configureLayout() {
        view.addSubview(navBar)
        view.addSubview(collectionView)
        view.addSubview(newMessageBtn)
//        addChild(sideVC)
//        view.addSubview(sideVC.view)
    }
    override func configureNavigation() {
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func configureConstraints() {
        navBar.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        newMessageBtn.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.width.equalTo(54)
        }
        
    }
    override func configureView() {
        navBar.title = "iOS Developers"
        collectionView.backgroundColor = .gray1
        configureCollectionView()
        newMessageBtn.rx.tap.bind(with: self) { owner, _ in
            let vc = WSwriterView<WScreateReactor>()
            vc.reactor = WScreateReactor(provider: ServiceProvider())
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            owner.present(nav,animated: true)
        }.disposed(by: disposeBag)
    }
    
}
