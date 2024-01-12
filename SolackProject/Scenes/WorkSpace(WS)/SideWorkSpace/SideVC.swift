//
//  SideView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift
import Combine
import Toast

final class SideVC: UIHostingController<Side>{
    var isOpen:Bool = false{
        didSet{ vm.isOpen = isOpen }
    }
    fileprivate var vm:SideVM
    var subscription = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()
    init(_ provider:ServiceProviderProtocol){
        self.vm = SideVM(provider)
        super.init(rootView: Side(vm:self.vm))
        isOpen = false
        vm.closeAction.sink { [weak self] _ in
            self?.view.isHidden = true
            self?.isOpen = false
            self?.dismiss(animated: false)
        }.store(in: &subscription)
        vm.getList()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        vm.createWorkSpaceTapped.sink { [weak self] _ in
            self?.presentCreateWS()
        }.store(in: &subscription) 
    }
    func presentCreateWS(){
        let vc = WSwriterView<WScreateReactor>()
        vc.reactor = WScreateReactor(vm.provider)
        let nav = UINavigationController(rootViewController: vc)
        if let sheet = nav.sheetPresentationController{
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav,animated: true)
    }
}
