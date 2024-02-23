//
//  ImageViewer.swift
//  SolackProject
//
//  Created by 김태윤 on 2/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
final class ImageViewer: BaseVC{
    var imagePathes:[String]!
    private var disposeBag = DisposeBag()
    private let taskCounter = TaskCounter()
    private let navBar = NavBar()
    private var dataSource: UICollectionViewDiffableDataSource<String,ImageItem>!
    let navigationTitle = BehaviorSubject<String>(value: "")
    private let navigationHidden = BehaviorSubject<Bool>(value: false)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    deinit{
        print("imageviewer 삭제!!")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoading = true
        Task{
            let images = try await taskCounter.run(imagePathes) { imageURL in
                guard let imageData = await NM.shared.getThumbnail(imageURL),let image = UIImage(data: imageData) else {
                    return ImageItem(imageURL: imageURL, image: .noPhotoA)
                }
                return ImageItem(imageURL: imageURL, image: image)
            }
            await MainActor.run {
                var snapshot = dataSource.snapshot()
                snapshot.deleteAllItems()
                snapshot.appendSections(["Hi"])
                snapshot.appendItems(images)
                dataSource.apply(snapshot,animatingDifferences: true)
                self.isLoading = false
            }
        }
        Task{
            try await Task.sleep(for: .seconds(5))
            await MainActor.run {
                guard self.isLoading else {return}
                let alert = SolackAlertVC(title: "이미지를 불러 올 수 없어요",
                                          description: "다시 시도해주세요",
                                          cancelTitle: "확인") {[weak self] in
                    self?.dismiss(animated: false){
                        self?.dismiss(animated: true)
                    }
                }
                alert.modalPresentationStyle = .overFullScreen
                self.present(alert, animated: false)
            }
        }
        navigationHidden.delay(.microseconds(100), scheduler: MainScheduler.instance).bind(with: self) { owner, isHidden in
            if isHidden{
                owner.navBar.alpha = 1
                UIView.animate(withDuration: 0.2) {
                    owner.navBar.alpha = 0
                }completion: { _ in
                    owner.navBar.isHidden = isHidden
                }
            }else{
                owner.navBar.alpha = 0
                owner.navBar.isHidden = isHidden
                UIView.animate(withDuration: 0.2) {
                    owner.navBar.alpha = 1
                }
            }
        }.disposed(by: disposeBag)
        navigationTitle.bind(with: self) { owner, title in
            owner.navBar.title = title
        }.disposed(by: disposeBag)
    }
    override func configureView() {
        let cellRegi = cellRegistration
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegi, for: indexPath, item: itemIdentifier)
        })
        self.collectionView.backgroundColor = .black
        navBar.closeTap.bind { [weak self] _   in
            self?.dismiss(animated: true)
        }.disposed(by:disposeBag)
        collectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Self.tapNavi)))
        navigationTitle.onNext("\(1) / \(imagePathes.count)")
    }
    override func configureNavigation() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.leftBarButtonItem = .init(systemItem: .close)
        navigationItem.leftBarButtonItem!.rx.tap.bind(with: self) { owner, _ in
            owner.dismiss(animated: true)
        }.disposed(by: disposeBag)
        navigationTitle.bind(with: self) { owner, title in
            owner.navigationItem.title = title
        }.disposed(by: disposeBag)
    }
    override func configureLayout() {
        self.view.addSubview(collectionView)
        self.view.addSubview(navBar)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide )
        }
        navBar.snp.makeConstraints { make in
            make.horizontalEdges.top.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(46)
        }
    }
    @objc func tapNavi(){
        navigationHidden.onNext(try! !navigationHidden.value())
    }
}
extension ImageViewer{
    final class NavBar:UIView{
        var title:String = ""{
            didSet{ label.text = title}
        }
        var closeTap: ControlEvent<Void>!
        private let closeBtn = UIButton()
        private let label:UILabel = .init()
        init() {
            super.init(frame: .zero)
            self.closeTap = closeBtn.rx.tap
            addSubview(label)
            addSubview(closeBtn)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            closeBtn.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(4)
                make.centerY.equalToSuperview()
            }
            var config = UIButton.Configuration.plain()
            config.image = .init(systemName: "chevron.left")
            config.preferredSymbolConfigurationForImage = .init(font: .boldSystemFont(ofSize: 17))
            config.baseForegroundColor = .white
            closeBtn.configuration = config
            label.font = .boldSystemFont(ofSize: 17)
            closeBtn.tintColor = .text
            label.textColor = .white
            label.textAlignment = .center
            self.backgroundColor = .black.withAlphaComponent(0.66)
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
    }
}
