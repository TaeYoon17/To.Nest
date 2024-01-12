//
//  WSwriter+Binding.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
extension WSwriterView{
    func bind(reactor: Reactor) {
        let createArr = [createBtn.rx.tap,workSpaceName.accAction,workSpaceDescription.accAction]
        createArr.forEach { (event: ControlEvent<Void>!) in
            event.map{_ in Reactor.Action.create}.bind(to: reactor.action).disposed(by:disposeBag)
        }
        workSpaceName.inputText.map{Reactor.Action.setName($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        workSpaceDescription.inputText.map{Reactor.Action.setDescription($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        profileVC.vm.imageData.map{Reactor.Action.imageData($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        // View Binding...
        reactor.state.map{$0.name}.bind(to: workSpaceName.inputText).disposed(by: disposeBag)
        reactor.state.map{$0.description}.bind(to: workSpaceDescription.inputText).disposed(by: disposeBag)
        [workSpaceName.authValid,workSpaceDescription.authValid].forEach{
            reactor.state.map{$0.isCreatable}.distinctUntilChanged().delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
                .bind(to: $0).disposed(by: disposeBag)
        }
        reactor.state.map{$0.isCreatable}.distinctUntilChanged()
            .delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
            owner.createBtn.isAvailable = value
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isLoading}.distinctUntilChanged().delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, value in
            owner.isLoading = value
        }.disposed(by: disposeBag)
    }
}
