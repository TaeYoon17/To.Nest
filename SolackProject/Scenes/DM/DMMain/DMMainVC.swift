//
//  DMMainVC.swift
//  SolackProject
//
//  Created by 김태윤 on 2/3/24.
//
import UIKit
import SnapKit
import ReactorKit
final class DMMainVC:BaseVC ,View{
    @DefaultsState(\.mainWS) var mainWS
    var disposeBag: DisposeBag = DisposeBag()
    func bind(reactor: DMMainReactor) {
        configureCollectionView(reactor: reactor)
        navBarBind(reactor: reactor)
        reactor.state.map{$0.dialog}.distinctUntilChanged().bind {[weak self] present in
            guard let self,let present else {return}
            switch present{
            case .room(roomID: let roomID, user: let userResponse):
                let vc = DMChatView()
                vc.reactor = DMChatReactor(reactor.provider, id: roomID, title: userResponse.nickname)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    let navBar = NaviBar()
    lazy var collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
    var dataSource: DataSource!
    override func configureLayout() {
        [navBar,collectionView].forEach { view.addSubview($0) }
    }
    override func configureNavigation() {
        navBar.title = "Direct Message"
        self.navigationController?.navigationBar.prefersLargeTitles = false
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
            make.bottom.equalToSuperview()
        }
    }
    override func configureView() {
        view.backgroundColor = .systemBackground
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        reactor!.provider.dmService.checkAll(wsID: mainWS.id)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.tabBarController?.tabBar.isHidden == true{
            self.tabBarController?.tabBar.layer.opacity = 0
            self.tabBarController?.tabBar.isHidden = false
            self.tabBarController?.tabBar.layoutIfNeeded()
            UIView.animate(withDuration: 0.1) {
                self.tabBarController?.tabBar.layer.opacity = 1
            }
        }
    }
}
