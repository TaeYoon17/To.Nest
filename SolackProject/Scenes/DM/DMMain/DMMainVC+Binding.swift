//
//  DMMainVC+Binding.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit

extension DMMainVC{
    //MARK: -- 내비바 Reactor 바인딩 설정
    func navBarBind(reactor:DMMainReactor){
        reactor.state.map{$0.wsThumbnail}.distinctUntilChanged()
            .delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, imageName in
                Task{
                    let myImage:UIImage
                    do{
                        myImage = try await UIImage.fetchWebCache(name: imageName, type: .small)
                    }catch{
                        let image = if let imageData = await NM.shared.getThumbnail(imageName){
                            UIImage.fetchBy(data: imageData, type:.small)
                        }else{
                            UIImage(resource: .wsThumbnail)
                        }
                        try await image.appendWebCache(name: imageName, type: .small, isCover: true)
                        myImage = try image.downSample(type: .small)
                    }
                    await MainActor.run {
                        owner.navBar.wsImage = myImage
                    }
                }
            }.disposed(by: disposeBag)
        self.navBar.profile.rx.tap.bind(with: self) { owner, _ in
            let vc = MyProfileVC(provider: reactor.provider)
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        reactor.state.map{$0.isProfileUpdated}
            .delay(.microseconds(100), scheduler: MainScheduler.instance).bind(with: self) { owner, value in
            guard value else {return}
            owner.navBar.updateMyProfileImage.onNext(())
        }.disposed(by: disposeBag)
    }
    //MARK: -- 멤버 리스트 Reactor 바인딩 설정
    func memberBind(reactor:DMMainReactor){
        
    }
    func dmEmptyBind(reactor: DMMainReactor){
        reactor.state.map{$0.membsers.count > 1 }.distinctUntilChanged().subscribe(on: MainScheduler.instance).bind(with: self) { owner, otherMemberExist in
            print("isEmpty!! \(otherMemberExist)")
            Task{@MainActor in
                owner.dmEmptyView.isHidden = otherMemberExist
            }
        }.disposed(by: disposeBag)
        dmEmptyView.tap.map{DMMainReactor.Action.inviteMemberAction}.bind(to: reactor.action).disposed(by: disposeBag)
    }
}
