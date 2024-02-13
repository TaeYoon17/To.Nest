//
//  WSSliderVC.swift
//  SolackProject
//
//  Created by 김태윤 on 1/18/24.
//

import UIKit
import SnapKit
final class WSSliderVC:SliderVC<WSMainVM>{
    var isShowKeyboard: CGFloat? = nil
    var toastY: CGFloat{ view.bounds.minY}
    var toastHeight: CGFloat = 0
    init(_ provider: ServiceProviderProtocol,sliderVM: SliderVM){
        let vm = WSMainVM(provider)
        vm.getList()
        super.init(viewVM: vm, sliderVM: sliderVM)
        sliderWSViewConnect(vm,sliderVM)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        wsMainBinding()
    }
    func wsMainBinding(){
        viewVM.createWorkSpaceTapped.sink { [weak self] _ in
            self?.presentCreateWS()
        }.store(in: &subscription)
        viewVM.changeWorkSpaceManagerTapped.sink { [weak self] _ in
            self?.presentManagerChangeWS()
        }.store(in: &subscription)
        viewVM.editWorkSpaceManagerTapped.sink { [weak self] _ in
            self?.presentEditWS()
        }.store(in: &subscription)
    }
    func sliderWSViewConnect(_ vm:WSMainVM,_ sliderVM:SliderVM){
        vm.closeAction.sink { [weak self] _ in
            sliderVM.endedSlider.onNext(false)
        }.store(in: &subscription)
        vm.$toastType.sink { [weak self] toast in
            guard let self else {return}
            sliderVM.toastPublisher.onNext(toast)
        }.store(in: &subscription)
    }
}
