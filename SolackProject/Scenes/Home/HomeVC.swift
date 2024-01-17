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
import Combine
import ReactorKit

final class HomeVC: BaseVC, View{
    var disposeBag = DisposeBag()
    var subscription = Set<AnyCancellable>()
    func bind(reactor: HomeReactor) {
        reactor.state.map{$0.channelDialog}.distinctUntilChanged().bind(with: self) { owner, present in
            guard let present else {return}
            switch present{
            case .create:
                let vc = CHWriterView(reactor.provider)
                let nav = UINavigationController(rootViewController: vc)
                nav.fullSheetSetting()
                owner.present(nav, animated: true)
            case .explore:
                let vc = CHExploreView()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                owner.present(nav, animated: true)
            }
        }.disposed(by: disposeBag)
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let navBar = NaviBar()
    var dataSource: HomeDataSource!
    let newMessageBtn = NewMessageBtn()
    var sliderVM = SliderVM()
    lazy var sliderVC = WSSliderVC(reactor!.provider, sliderVM: sliderVM)
    
    override var prefersStatusBarHidden: Bool { false }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar.workSpaceTap.bind(with: self) { owner, _ in
            // 슬라이드 뷰 구현 with swiftui
        }.disposed(by: disposeBag)
        sliderVM.sliderPresent.bind(with: self) { owner, _ in
            owner.present(owner.sliderVC, animated: false)
        }.disposed(by: disposeBag)
        print("tempVM 받음!!")
    }
    override func configureLayout() {
        view.addSubview(navBar)
        view.addSubview(collectionView)
        view.addSubview(newMessageBtn)
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
            let vc = WSwriterView<WScreateReactor>(.create,reactor: WScreateReactor(owner.reactor!.provider))
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            owner.present(nav,animated: true)
        }.disposed(by: disposeBag)
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Self.edgeSwipe(_:)))
        edgeGesture.edges = .left
        self.view.addGestureRecognizer(edgeGesture)
    }
    
}

