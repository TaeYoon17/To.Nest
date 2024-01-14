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
        //MARK: -- View Binding...
        // 워크스페이스 이름 텍스트 필드
        reactor.state.map{$0.name}.bind(to: workSpaceName.inputText).disposed(by: disposeBag)
        // 설명 텍스트 필드
        reactor.state.map{$0.description}.bind(to: workSpaceDescription.inputText).disposed(by: disposeBag)
        // 에러 색성 처리
        [workSpaceName.authValid,workSpaceDescription.authValid].forEach{
            reactor.state.map{$0.isCreatable}.distinctUntilChanged().delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
                .bind(to: $0).disposed(by: disposeBag)
        }
        // 생성 버튼 처리
        reactor.state.map{$0.isCreatable}.distinctUntilChanged()
            .delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
            owner.createBtn.isAvailable = value
        }.disposed(by: disposeBag)
        // 로딩 처리
        reactor.state.map{$0.isLoading}.distinctUntilChanged().delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, value in
            owner.isLoading = value
        }.disposed(by: disposeBag)
        // 창 닫기
        reactor.state.map{$0.isClose}.distinctUntilChanged().delay(.milliseconds(1000), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, value in
            if value{ owner.dismiss(animated: true) }
        }.disposed(by: disposeBag)
        // 알림 처리
        failAlertBinding(reactor: reactor)
        // 이미지 바인딩 처리
        reactor.state.map{$0.imageData}.distinctUntilChanged().delay(.microseconds(1000), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, data in
            owner.profileVC.vm.defaultImage.send(data) // 프로필 이미지 데이터와 통신... 단일 데이터로 캐싱하지 말자... default 이미지를 바꿔주는 역할이다.
        }.disposed(by: disposeBag)
        
        //MARK: -- 액션 바인딩...
        createArr.forEach { (event: ControlEvent<Void>!) in
            event.map{_ in Reactor.Action.confirmAction}.bind(to: reactor.action).disposed(by:disposeBag)
        }
        workSpaceName.inputText.map{Reactor.Action.setName($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        workSpaceDescription.inputText.map{Reactor.Action.setDescription($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        profileVC.vm.imageData.map{Reactor.Action.setImageData($0)}.bind(to: reactor.action).disposed(by: disposeBag)
       
    }
}
extension WSwriterView{
    func failAlertBinding(reactor: Reactor){
        reactor.state.map{$0.failAlert}.distinctUntilChanged().bind(with: self) { owner, failed in
            switch failed{
            case .lackCoin:
                let vc = SolackAlertVC(title: "코인이 부족합니다", description: "돈을 더 줘", cancelTitle: "확인", cancel: { print("확인") })
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc,animated: false)
            case .nonAuthority:
                let vc = SolackAlertVC(title: "권한이 없습니다", description: "필요한건 관리자 권한", cancelTitle: "확인", cancel: { print("확인") })
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc,animated: false)
            default: return
            }
        }.disposed(by: disposeBag)
    }
}
