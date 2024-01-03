//
//  SignUpView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//
import UIKit
import SnapKit
import ReactorKit
final class SignUpView:BaseVC,View{
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    let signUpBtn = UIButton()
    
    var disposeBag: DisposeBag = .init()
    func bind(reactor: SignUpViewReactor) {
        reactor.state.map{$0.isSignUpAble}.subscribe(with: self){ owner,val in
            let config = owner.signUpBtn.config.foregroundColor(.white).cornerRadius(8).text("가입하기", font: .title2)
            config.backgroundColor(val ? .accent : .gray4).apply()
        }.disposed(by: disposeBag)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureView() {
        
    }
    override func configureLayout() {
        view.addSubview(collectionView)
        view.addSubview(signUpBtn)
    }
    override func configureNavigation() {
        self.navigationItem.leftBarButtonItem = .init(image: .init(systemName: "xmark"))
        self.navigationItem.leftBarButtonItem?.tintColor = .text
        self.navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true){
//                owner.reactor?.provider.authService.navigation.onNext(.dismissCompleted)
            }
        }.disposed(by: disposeBag)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        signUpBtn.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
}
