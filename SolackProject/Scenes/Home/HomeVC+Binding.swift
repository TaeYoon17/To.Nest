//
//  HomeVC+Binding.swift
//  SolackProject
//
//  Created by 김태윤 on 2/6/24.
//
import RxSwift
import UIKit

extension HomeVC{
    //MARK: -- 네비게이션 바
    func naviBinding(reactor: HomeReactor){
        // 프로필 이미지 업데이트 시키기... 깃 머지시 고려사항
        reactor.state.map{$0.isProfileUpdated}.distinctUntilChanged().bind(with: self) { owner, value in
            guard value else {return}
            owner.navBar.updateMyProfileImage.onNext(())
        }.disposed(by: disposeBag)
        reactor.state.map{$0.wsTitle}.distinctUntilChanged()
            .delay(.microseconds(100), scheduler: MainScheduler.asyncInstance).bind(with: self) { owner, title in
            owner.navBar.title = title
        }.disposed(by: disposeBag)
        reactor.state.map{$0.wsLogo}.distinctUntilChanged()
            .delay(.microseconds(100), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, imageName in
                Task{
                    let myImage:UIImage
                    do{
                        myImage = try await UIImage.fetchWebCache(name: imageName, type: .small)
                        print("캐시 데이터 잘 가져옴!!")
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
    }
}
//MARK: -- 화면전환 바인딩
extension HomeVC{
    func transitionBinding(reactor: HomeReactor){
        reactor.state.map{$0.channelDialog}.distinctUntilChanged().subscribe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] presentType in
                guard let self, let presentType else {return}
                switch presentType{
                case .create:
                    let vc = CHWriterView(reactor.provider,type: .create)
                    let nav = UINavigationController(rootViewController: vc)
                    nav.fullSheetSetting()
                    present(nav, animated: true)
                case .explore:
                    let vc = CHExploreView()
                    vc.vm = CHExploreVM(provider: reactor.provider,myChannels: reactor.currentState.channelList)
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    present(nav, animated: true)
                case .chatting(chID: let chID,chName: let name):
                    print("채팅 뷰 이동 \(chID) \(name)")
                    let chatReactor = CHChatReactor(reactor.provider, id: chID, title: name)
                    let vc = CHChatView()
                    vc.reactor = chatReactor
                    navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: disposeBag)
        reactor.state.map{$0.isMasking}.distinctUntilChanged()
            .delay(.microseconds(2000), scheduler: MainScheduler.asyncInstance)
            .bind(with: self) { owner, value in
                guard let value else {return}
                Task{@MainActor in
                    if value{
                        UIView.animate(withDuration: 0.3) {
                            owner.navBar.title = "Empty WorkSpace"
                            owner.navBar.wsImage = .wsThumbnail
                            owner.tabBarController?.tabBar.isHidden = true
                            owner.wsEmpty.isHidden = false
                            owner.view.layoutIfNeeded()
                        }
                    }else{
                        owner.tabBarController?.tabBar.isHidden = false
                        owner.wsEmpty.isHidden = true
                        owner.view.layoutIfNeeded()
                        owner.navBar.layoutIfNeeded()
                    }
                }
            }.disposed(by: disposeBag)
    }
}
