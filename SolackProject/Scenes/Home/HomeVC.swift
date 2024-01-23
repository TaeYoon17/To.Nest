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
        reactor.state.map{$0.wsTitle}.distinctUntilChanged()
            .delay(.microseconds(100), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, title in
            owner.navBar.title = title
        }.disposed(by: disposeBag)
        reactor.state.map{$0.wsLogo}.distinctUntilChanged()
            .delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, imageName in
                Task{
                    let myImage:UIImage
                    do{
                        myImage = try await UIImage.fetchWebCache(name: imageName, type: .small)
                        print("캐시 데이터 잘 가져옴!!")
                    }catch{
                        let image = if let imageData = await NM.shared.getThumbnail(imageName){
                            UIImage.fetchBy(data: imageData, type:.small)
                        }else{
                            UIImage(resource: .wsThumbnail)
                        }
                        try await image.appendWebCache(name: imageName, type: .small, isCover: true)
                        myImage = try image.downSample(type: .small)
                    }
                    await MainActor.run {
                        owner.navBar.wsImage = myImage
                    }
                }
            }.disposed(by: disposeBag)
        reactor.state.map{$0.channelDialog}.distinctUntilChanged().subscribe(on: MainScheduler.instance).bind(with: self) { owner, present in
            guard let present else {return}
            switch present{
            case .create:
                let vc = CHWriterView(reactor.provider,type: .create)
                let nav = UINavigationController(rootViewController: vc)
                nav.fullSheetSetting()
                owner.present(nav, animated: true)
            case .explore:
                let vc = CHExploreView()
                vc.vm = CHExploreVM(provider: reactor.provider,myChannels: reactor.currentState.channelList)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                owner.present(nav, animated: true)
            case .chatting(chID: let chID):
                let vc = CHChatView()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isMasking}.distinctUntilChanged()
            .delay(.microseconds(2000), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                guard let value else {return}
                Task{@MainActor in
                    if value{
                        UIView.animate(withDuration: 0.3) {
                            owner.navBar.title = "Empty WorkSpace"
                            owner.navBar.wsImage = .wsThumbnail
                            owner.tabBarController?.tabBar.isHidden = true
                            owner.wsEmpty.isHidden = false
                            owner.view.layoutIfNeeded()
                        }
                    }else{
                        owner.tabBarController?.tabBar.isHidden = false
                        owner.wsEmpty.isHidden = true
                        owner.view.layoutIfNeeded()
                        owner.navBar.layoutIfNeeded()
                    }
                }
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
    var wsEmpty: WSEmpty = .init()
    
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
        reactor?.action.onNext(.initMainWS)
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
            let vc = WSwriterView<WScreateReactor>(.create,reactor: WScreateReactor(owner.reactor!.provider))
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

