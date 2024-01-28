//
//  CHChatView+Bindings.swift
//  SolackProject
//
//  Created by 김태윤 on 1/27/24.
// 리액터와 통신하는 뷰 컴포넌트마다의 바인딩 함수 묶어두기

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Combine
extension CHChatView{
    typealias Action = CHChatReactor.Action
    func naviBarBinding(reactor: CHChatReactor){
        Observable.combineLatest(reactor.state.map{$0.memberCount}, reactor.state.map{$0.title})
            .bind(with: self) { owner, args in
            var (number, title) = args
            owner.updateTitleLabel(title: title, number: number)
        }.disposed(by: disposeBag)
        chatField.text.map{CHChatReactor.Action.setChatText($0)}.bind(to: reactor.action).disposed(by: disposeBag)
    }
    func textFieldBinding(reactor: CHChatReactor){
        
        // 채팅 전송 버튼 탭
        chatField.send.map{Action.actionSendChat}.bind(to: reactor.action).disposed(by: disposeBag)
        // 이미지 항목 하나 삭제
        chatField.deleteImageItem.map{Action.setDeleteImage($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        
        // 메시지 전송 가능
        reactor.state.map{$0.isActiveSend}.bind(to: chatField.isActiveSend).disposed(by: disposeBag)
        //MARK: -- 이미지 추가
        // 앨범 이미지 추가 버튼 클릭
        chatField.addImages.map{Action.addImages}.bind(to: reactor.action).disposed(by: disposeBag)
        chatField.addImages.bind(with: self) { owner, _ in
            owner.dismissMyKeyboard()
        }.disposed(by: disposeBag)
        
        // 뷰모델(리엑터)에서 이전에 사용한 앨범 이미지 정보를 가져와 앨범 present 띄우기
        reactor.state.map{$0.prevIdentifiers}.distinctUntilChanged()
            .subscribe(on: MainScheduler.asyncInstance).bind(with: self) { owner, ids in
                guard let ids else {return}
                PM.shared.presentPicker(vc: owner,multipleSelection: true,prevIdentifiers: ids)
                Task{
                    try await Task.sleep(for: .seconds(1))
                    await MainActor.run {
                        owner.progressView.progress.setProgress(0, animated: false)
                        owner.progressView.isHidden = false
                    }
                }
            }.disposed(by: disposeBag)
        // 앨범 present 작업이 끝나면, present 띄운 뷰 컨트롤러 정보, 새로 추가할 파일들, 이전에 사용한 앨범 파일 중 계속 사용할 것의 아이디를 가져옴
        PM.shared.fileResults.bind { [weak self] vc,fileDatas,remains in
            guard let self else {return}
            // 현재 뷰 컨트롤러와 앨범에서 사용한 뷰 컨트롤러가 같아야만한다.
            guard self == vc else {return}
            // 리액터에 현재 사용할 이미지들 정보의 변경 사항을 보낸다.
            reactor.action.onNext(.setSendFiles(fileDatas,remains))
            Task{@MainActor in
                self.progressView.isHidden = true
            }
        }.disposed(by: disposeBag)
        // 사용할 이미지들의 정보들을 가져온다.
        reactor.state.map{$0.sendFiles}
            .distinctUntilChanged()
            .map{ $0.map{ data in
                ImageViewerItem(imageID: data.name, image: UIImage.fetchBy(data: data.file,size: .init(width: 44, height: 44)))
                }}
            .subscribe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, items in
                Task{
                    await MainActor.run {
                        owner.chatField.hiddenImageView = items.isEmpty
                        owner.chatField.imageFiles.onNext(items)
                    }
                }
            }).disposed(by: disposeBag)
        Task{
            await PM.shared.counter.progressRatio.sink{[weak self] ratio in
                self?.progressView.progressNumber.onNext(ratio)
            }.store(in: &subscription)
        }
    }
}
