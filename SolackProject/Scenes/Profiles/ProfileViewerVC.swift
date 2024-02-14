//
//  ProfileViewerVC.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import UIKit
import SwiftUI
import RxSwift
import RxCocoa

final class ProfileViewerVC:UIHostingController<ProfileViewer>{
    var disposeBag = DisposeBag()
    init(provider:ServiceProviderProtocol,userID:Int){
        let vm = ProfileViewerVM(provider: provider, userID: userID)
        super.init(rootView: ProfileViewer(vm: vm))
        vm.goBackNavigation.bind { [weak self] _ in
            self?.dismiss(animated: true)
        }.disposed(by: disposeBag)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.text = "프로필"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        navigationItem.titleView = label
        navigationItem.leftBarButtonItem = .getBackBtn
        navigationItem.leftBarButtonItem?.tintColor = .text
        navigationItem.leftBarButtonItem!.rx.tap.bind { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
}
struct ProfileViewer:View{
    @ObservedObject var vm: ProfileViewerVM
    let size = UIScreen.main.bounds.width - 160
    var body: some View{
        List {
            Section {
                HStack(content: {
                    Text("닉네임").font(FontType.bodyBold.font)
                    Spacer()
                    Text(vm.nickName).font(FontType.body.font)
                        .foregroundStyle(.secondary)
                })
                HStack(content: {
                    Text("이메일").font(FontType.bodyBold.font)
                    Spacer()
                    Text(vm.email).font(FontType.body.font)
                        .foregroundStyle(.secondary)
                })
            }header: {
                HStack{
                    Spacer()
                    vm.image.resizable().frame(width: size,height:size)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }.padding(.top,24).padding(.bottom,33)
            }
                .listRowSeparator(.hidden)
        }.listStyle(.insetGrouped)
            .navigationBarBackButtonHidden()
//            .toolbar(content: {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button{
//                        vm.goBackNavigation.onNext(())
//                    }label: {
//                        Image(systemName: "chevron.left").font(.system(size: 17,weight: .bold))
//                    }.tint(.text)
//                }
//                ToolbarItem(placement: .principal) {
//                    Text("프로필").font(.system(size: 17,weight: .bold))
//                        .foregroundStyle(.text)
//                }
//            })
    }
}
