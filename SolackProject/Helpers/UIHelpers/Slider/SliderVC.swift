//
//  SliderVC.swift
//  SolackProject
//
//  Created by 김태윤 on 1/17/24.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import SwiftUI
import Combine
final class SliderVM: ObservableObject{
    var slider = PublishSubject<CGFloat>()
    var endedSlider = PublishSubject<Bool>()
    var sliderPresent = PublishSubject<()>()
}

class SliderVC<T:ObservableObject>:BaseVC{
    var viewVM:T
    private weak var sliderVM: SliderVM!
     var subscription = Set<AnyCancellable>()
     var disposeBag = DisposeBag()
    private lazy var sliderWidth = UIScreen.current!.bounds.width * 0.85
    private lazy var dismissView = UIView()
    private lazy var sliderView = Slider(sliderVM,viewVM)
    override var prefersStatusBarHidden: Bool { true }

    init(viewVM vm: T,sliderVM:SliderVM){
        self.viewVM = vm
        self.sliderVM = sliderVM
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func configureView() {
        view.backgroundColor = .clear
        dismissView.backgroundColor = .clear
        let tapGesgure = UITapGestureRecognizer(target: self, action: #selector(Self.dimissTapGesture(_:)))
        self.dismissView.addGestureRecognizer(tapGesgure)
    }
    override func configureLayout() {
        self.addChild(sliderView)
        view.addSubview(sliderView.view)
        view.addSubview(dismissView)
    }
    override func configureConstraints() {
        sliderView.view.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().offset(-sliderWidth)
            make.width.equalTo(sliderWidth)
        }
        dismissView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(UIScreen.current!.bounds.width - sliderWidth)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderBinding()
        wsMainBinding()
    }
    @objc private func dimissTapGesture(_ gesture: UITapGestureRecognizer){
        Task{@MainActor in
            sliderVM.slider.onNext(0)
            try await Task.sleep(for: .seconds(0.3))
            self.dismiss(animated: false)
        }
    }
    func wsMainBinding(){
        fatalError("It must be override!!")
    }
}
//MARK: -- SliderVM 통신 binder
extension SliderVC{
    fileprivate func sliderBinding(){
        sliderVM.slider.bind(with: self) { owner, value in
            let value = max(0,min(value,owner.sliderWidth))
            UIView.animate(withDuration: 0.2) {
                owner.view.backgroundColor = .gray.withAlphaComponent(0.666)
                owner.sliderView.view.transform = CGAffineTransform(translationX: value, y: 0)
            }
        }.disposed(by: disposeBag)
        sliderVM.endedSlider.bind(with: self) { owner, value in
            UIView.animate(withDuration: 0.25) {
                owner.view.backgroundColor = .gray.withAlphaComponent(value ? 0.666 : 0)
                owner.sliderView.view.transform = CGAffineTransform(translationX: value ? owner.sliderWidth : 0, y: 0)
            }completion: { _ in
                if !value{ owner.dismiss(animated: false) }
            }
        }.disposed(by: disposeBag)
    }
}
//MARK: -- SideVM 통신 Binder
extension WSSliderVC{
    func presentCreateWS(){
        let vc = WSwriterView<WScreateReactor>(.create,reactor: WScreateReactor(viewVM.provider))
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController{
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav,animated: true)
    }
    func presentManagerChangeWS(){
        let vc = WSManagerView()
        vc.reactor = WSManagerReactor(provider: viewVM.provider)
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController{
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav,animated: true)
    }
    func presentEditWS(){
        let listData = viewVM.underList[viewVM.selectedIdx]
        let info = WSInfo(name: listData.name,description: listData.description ?? "",image: viewVM.list[viewVM.selectedIdx].image.jpegData(compressionQuality: 1))
        let vc = WSwriterView<WSEditReactor>(.edit,reactor: WSEditReactor(provider: viewVM.provider, wsInfo: info,id:"\(viewVM.selectedWorkSpaceID)"))
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController{
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav,animated: true)
    }
}
