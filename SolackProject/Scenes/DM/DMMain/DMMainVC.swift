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
    var disposeBag: DisposeBag = DisposeBag()
    func bind(reactor: DMMainReactor) {
        
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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func configureConstraints() {
        navBar.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
    }
    override func configureView() {
        view.backgroundColor = .systemBackground
    }
}
