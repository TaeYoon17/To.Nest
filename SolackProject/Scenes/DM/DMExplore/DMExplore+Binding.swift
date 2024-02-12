//
//  DMInviteView+Binding.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import UIKit
import RxSwift
extension DMExplore{
    func dialogAndCloseBind(reactor: DMExploreReactor){
        reactor.state.map{$0.isClose}.distinctUntilChanged().subscribe(on: MainScheduler.instance).bind(with: self) { owner, val in
            if val{
                Task{@MainActor in
                    owner.dismiss(animated: true)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    func toastBind(reactor : WSManagerReactor){
        reactor.state.map{$0.toast}.subscribe(on: MainScheduler.instance).bind(with: self) { owner, toast in
            guard let toast else {return }
            owner.toastUp(type: toast)
        }.disposed(by: disposeBag)
    }
}
