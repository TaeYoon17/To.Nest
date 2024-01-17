//
//  WSSliderVC.swift
//  SolackProject
//
//  Created by 김태윤 on 1/18/24.
//

import UIKit
import SnapKit
final class WSSliderVC:SliderVC<WSMainVM>{
    init(_ provider: ServiceProviderProtocol,sliderVM: SliderVM){
        let vm = WSMainVM(provider)
        vm.getList()
        super.init(viewVM: vm, sliderVM: sliderVM)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func wsMainBinding(){
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
}
