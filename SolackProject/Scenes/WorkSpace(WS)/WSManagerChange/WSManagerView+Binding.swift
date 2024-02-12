//
//  WSManagerView+Bind.swift
//  SolackProject
//
//  Created by 김태윤 on 2/11/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

extension WSManagerView{
    func dialogAndCloseBind(reactor: WSManagerReactor){
        reactor.state.map{$0.wsManagerDialog}.delay(.microseconds(100), scheduler: MainScheduler.instance).bind(with: self) { owner, dialogType in
            guard let dialogType else {return }
            switch dialogType{
            case .checkAlert(userNick: let nick, userID: let userID):
                let title = "\(nick) 님을 관리자로 지정하시겠습니까?"
                let desc = "워크스페이스 관리자는 다음과 같은 권한이 있습니다."
                let infos = ["워크스페이스 이름 또는 실명 변경","워크스페이스 삭제","워크스페이스 멤버 초대"]
                let vc = SolackAlertVC(title: title, description: desc, infos: infos, cancelTitle: "취소", cancel: {}, confirmTitle: "확인") {
                    reactor.action.onNext(.confirmAdminChangeAction(userID: userID))
                }
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc,animated: false)
            case .nonMember:
                let txt = "워크스페이스 멤버가 없어 관리자 변경을 할 수 없습니다.\n새로운 멤버를 워크스페이스에 초대해보세요."
                let vc = SolackAlertVC(title: "워크스페이스 관리자 변경 불가", description: txt, cancelTitle: "확인", cancel: {})
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc,animated: false)
            }
        }.disposed(by: disposeBag)
        
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
