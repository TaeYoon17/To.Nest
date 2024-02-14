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

final class HomeVC: BaseVC, View,Toastable{
    var disposeBag = DisposeBag()
    var subscription = Set<AnyCancellable>()
    func bind(reactor: HomeReactor) {
        naviBinding(reactor: reactor)
        transitionBinding(reactor: reactor)
        reactor.state.map{$0.toast}.delay(.microseconds(100), scheduler: MainScheduler.instance).bind(with: self) { owner, type in
            guard let type else {return}
            owner.toastUp(type: type)
        }.disposed(by: disposeBag)
        wsEmpty.btnTapped.bind(with: self) { owner, _ in
            let vc = WSwriterView(.create, reactor: WScreateReactor(reactor.provider))
            let nav = UINavigationController(rootViewController: vc)
            nav.fullSheetSetting()
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
    }
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let navBar = NaviBar()
    var dataSource: HomeDataSource!
    let newMessageBtn = NewMessageBtn()
    var sliderVM = SliderVM()
    lazy var sliderVC = WSSliderVC(reactor!.provider, sliderVM: sliderVM)
    var wsEmpty: WSEmpty = {
        let view = WSEmpty()
        view.isHidden = true
        return view
    }()
    var isShowKeyboard: CGFloat? = nil
    var toastY: CGFloat{ collectionView.frame.maxY-(toastHeight / 2) - 20 }
    var toastHeight: CGFloat = 0
    override var prefersStatusBarHidden: Bool { false }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBar.workSpaceTap.bind(with: self) { owner, _ in
            // 슬라이드 뷰 구현 with swiftui
            owner.sliderVM.sliderPresent.onNext(())
            owner.sliderVM.endedSlider.onNext(true)
        }.disposed(by: disposeBag)
        sliderVM.sliderPresent.bind(with: self) { owner, _ in
            owner.present(owner.sliderVC, animated: false)
        }.disposed(by: disposeBag)
        reactor?.action.onNext(.initMainWS)
        navBar.profile.rx.tap.bind(with: self) { owner, _ in
            let vc = MyProfileVC(provider: owner.reactor!.provider)
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureLayout() {
        view.addSubview(navBar)
        view.addSubview(collectionView)
        view.addSubview(newMessageBtn)
        view.addSubview(wsEmpty)
    }
    override func configureNavigation() {
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func configureConstraints() {
        navBar.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(46)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide )
        }
        newMessageBtn.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(18)
            make.height.width.equalTo(60)
        }
        wsEmpty.snp.makeConstraints { make in
            make.top.equalTo(navBar.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(24)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if self.tabBarController!.tabBar.isHidden{
            self.tabBarController?.tabBar.layer.opacity = 0
        }
        reactor?.action.onNext(.updateUnreads)
//        reactor!.provider.wsService.checkAllMembers()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let isMask = reactor?.currentState.isMasking, isMask == false  {
            self.tabBarController?.tabBar.isHidden = false
        }
        UIView.animate(withDuration: 0.3) {
            self.tabBarController?.tabBar.layer.opacity = 1
        }
    }
    override func configureView() {
        collectionView.backgroundColor = .gray1
        configureCollectionView()
        newMessageBtn.rx.tap.bind(with: self) { owner, _ in
            let vc = WSInviteView()
            vc.reactor = WSInviteReactor(owner.reactor!.provider)
            let nav = UINavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            owner.present(nav,animated: true)
        }.disposed(by: disposeBag)
        
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Self.edgeSwipe(_:)))
        let edgeGesture2 = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(Self.edgeSwipe(_:)))
        edgeGesture.edges = .left
        edgeGesture2.edges = .left
        self.view.addGestureRecognizer(edgeGesture2)
        self.wsEmpty.addGestureRecognizer(edgeGesture)
    }
    
}

