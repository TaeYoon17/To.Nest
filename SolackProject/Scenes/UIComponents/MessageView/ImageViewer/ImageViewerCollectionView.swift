//
//  ImageViewerCollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/22/24.
//

import UIKit
import RxSwift

extension ImageViewer{
    var layout: UICollectionViewLayout{
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.scrollDirection = .horizontal
        layout.configuration = layoutConfig
        section.visibleItemsInvalidationHandler = { [weak self] ( visibleItems, offset, env) in
            guard let indexPath = visibleItems.last?.indexPath else {return}
            guard let self else {return}
            navigationTitle.onNext("\(indexPath.row) / \(imagePathes.count)")
        }
        return layout
    }
    var cellRegistration: UICollectionView.CellRegistration< ImageCell,ImageItem>{
        UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.image = itemIdentifier.image
        }
    }
    final class ImageCell:UICollectionViewCell,UIScrollViewDelegate{
        var image:UIImage?{
            didSet{
                guard let image else {return}
                self.imageView.image = image
            }
        }
        private lazy var imageView = {
            let imgView = UIImageView()
            imgView.image = UIImage(systemName: "heart")
            imgView.contentMode = .scaleAspectFit
            return imgView
        }()
        private let scrollView = UIScrollView()
        private var scale:CGFloat = 1
        private var point: CGPoint = .zero
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.contentView.addSubview(scrollView)
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            scrollView.delegate = self
            scrollView.maximumZoomScale = 3.0
            scrollView.minimumZoomScale = 0.8
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.backgroundColor = .black
            scrollView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalToSuperview()
            }
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            self.imageView
        }
    }
    struct ImageItem:Identifiable,Hashable{
        var id:String{imageURL}
        let imageURL:String
        let image: UIImage
    }
}
//@objc func pinchGesture(recognizer sender: UIPinchGestureRecognizer){
//    if sender.state == .ended || sender.state == .changed {
//
//        // frame은 transform이 변화면 바뀐다.
//        let currentScale = self.imageView.frame.size.width / self.imageView.bounds.size.width
//        var newScale = currentScale*sender.scale
//        if newScale < 1 {
//            newScale = 1
//        }
//        if newScale > 9 { newScale = 9}
//        self.scale = newScale
//        let transform = CGAffineTransformMakeScale(newScale, newScale).translatedBy(x: self.point.x, y: self.point.y)
//        self.imageView.transform = transform
//        sender.scale = 1
//    }
//}
//@objc func translateGesture(recognizer sender: UIPanGestureRecognizer){
////            self.imageView.transform
//    let point = sender.translation(in: self.imageView)
//    switch sender.state{
//    case .began:break
//    case .ended: break
////                self.point = poin
//    case .changed:
//        let transform = CGAffineTransform(translationX: point.x, y: point.y).scaledBy(x: self.scale, y: self.scale)
//        print(transform)
//    default: break
//    }
//    print("translate",point)
//    
//}
