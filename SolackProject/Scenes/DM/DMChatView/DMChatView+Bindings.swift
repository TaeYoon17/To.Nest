//
//  DMChatView+Bindings.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Combine

extension DMChatView{
    typealias Action = DMChatReactor.Action
    func naviBarBinding(reactor: DMChatReactor){
        reactor.state.map{$0.title}.subscribe(on: MainScheduler.asyncInstance).bind { [weak self] title in
            self?.updateTitleLabel(title: title)
        }.disposed(by: disposeBag)
    }
    func textFieldBinding(reactor: DMChatReactor){
        msgField.send.map{Action.actionSendChat}.bind(to: reactor.action).disposed(by: disposeBag)
        msgField.deleteImageItem.map{Action.setDeleteImage($0)}.bind(to: reactor.action).disposed(by: disposeBag)
        reactor.state.map{$0.isActiveSend}.bind(to: msgField.isActiveSend).disposed(by: disposeBag)
        msgField.addImages.map{Action.addImages}.bind(to: reactor.action).disposed(by: disposeBag)
        msgField.addImages.bind(with: self) { owner, _ in
            owner.dismissMyKeyboard()
        }.disposed(by: disposeBag)
        
        reactor.state.map{$0.prevIdentifiers}.distinctUntilChanged()
            .subscribe(on: MainScheduler.asyncInstance).bind { [weak self] ids in
                guard let ids,let self else {return}
                PM.shared.presentPicker(vc: self,multipleSelection:true,prevIdentifiers: ids)
                Task{
                    try await Task.sleep(for: .seconds(1))
                    await MainActor.run {
                        self.progressView.progress.setProgress(0, animated: false)
                        self.progressView.isHidden = false
                    }
                }
            }.disposed(by: disposeBag)
        PM.shared.fileResults.bind { [weak self] vc, fileDatas,remains in
            guard let self, self == vc else {return}
            reactor.action.onNext(.setSendFiles(fileDatas, remains))
            Task{@MainActor in
                self.progressView.isHidden = true
            }
        }.disposed(by: disposeBag)
        reactor.state.map{$0.sendFiles}
            .distinctUntilChanged()
            .map{ $0.map{ data in
                MSGImageViewerItem(imageID: data.name, image: UIImage.fetchBy(data: data.file,size: .init(width: 44, height: 44)))
                }}
            .subscribe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, items in
                Task{
                    await MainActor.run {
                        owner.msgField.hiddenImageView = items.isEmpty
                        owner.msgField.imageFiles.onNext(items)
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
