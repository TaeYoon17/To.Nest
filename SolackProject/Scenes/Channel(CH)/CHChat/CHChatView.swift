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
final class CHChatView: BaseVC{
    @MainActor lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    var dataSource: DataSource!
    lazy var naviTitleView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .gray3
        return view
    }()
    var disposeBag = DisposeBag()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func configureNavigation() {
        let label = UILabel()
        let number = 14
        let fullText = if number <= 0{ "#그냥 떠들고 싶을 때" } else { "#그냥 떠들고 싶을 때 \(number)" }
        let attributedString = NSMutableAttributedString(string: fullText,attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.text
        ])
        if number > 0{
            let range = (fullText as NSString).range(of: "\(14)")
            attributedString.addAttribute(.foregroundColor, value: UIColor.secondary, range: range)
        }
        label.attributedText = attributedString
        self.navigationItem.titleView = label
        self.navigationItem.leftBarButtonItem = .getBackBtn
        self.navigationItem.rightBarButtonItem = .init(image: .init(systemName: "list.bullet",withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17))))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationItem.rightBarButtonItem?.tintColor = .text
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            let vc = CHSettingView()
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    override func configureLayout() {
        self.view.addSubview(collectionView)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func configureView() {
        configureCollectionView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    }
}
extension UIBarButtonItem{
    static var getBackBtn: UIBarButtonItem{
        UIBarButtonItem(image: .init(systemName: "chevron.left",withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17))))
    }
}

