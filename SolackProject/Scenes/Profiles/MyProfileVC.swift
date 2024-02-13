//
//  MyProfileVC.swift
//  SolackProject
//
//  Created by 김태윤 on 1/30/24.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import RxSwift
final class MyProfileVC: UIHostingController<MyProfileView>{
    var subscription = Set<AnyCancellable>()
    var disposeBag = DisposeBag()
    init(provider: ServiceProviderProtocol){
        let vm = MyProfileReactor(provider)
        let imgVM = ProfileImgVM()
        super.init(rootView: MyProfileView(vm: vm,imgVM: imgVM))
        vm.goHome.sink { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.store(in: &subscription)
        imgVM.imageData.bind(with: self) { owner, data in
            vm.action.onNext(.setImage(data))
        }.disposed(by: disposeBag)
        vm.state.map{$0.image}.bind(with: self) { owner, data in
            Task{@MainActor in imgVM.defaultImage.send(data) }
        }.disposed(by: disposeBag)
        vm.logOutTapped.sink { [weak self] _ in
            self?.logOutAction(vm:vm)
        }.store(in: &subscription)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.2) {
            self.tabBarController?.tabBar.alpha = 0
        }completion: { _ in
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    private func logOutAction(vm:MyProfileReactor){
        let vc = SolackAlertVC(title: "로그아웃", description: "정말 로그아웃 할까요?", cancelTitle: "취소", cancel: {},confirmTitle: "로그아웃",
                               confirm: {[weak self] in
            vm.logOut()
        })
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
}
extension MyProfileView{
    enum NaviType{
        case nickname
        case call
    }
    enum VendorType:String{
        case kakao
        case apple
    }
}
struct MyProfileView:View{
    @ObservedObject var vm: MyProfileReactor
    @ObservedObject var imgVM :ProfileImgVM
    @DefaultsState(\.myInfo) var myInfo
    @State var vendor: VendorType? = nil
    @State var isLogOut:Bool = false
    var body: some View{
        NavigationStack {
            List{
                HStack{
                    Spacer()
                    MyProfileEditImageView(vm: imgVM, prevImage: true)
                    Spacer()
                }
                .listRowSpacing(0)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 12, trailing: 0))
                .background(.gray2)
                .listRowBackground(Color.gray2)
                Section {
                    HStack{
                        (
                            Text("내 새싹 코인 ")+Text(" 130").foregroundColor(.accent)
                        ).font(FontType.bodyBold.font).foregroundStyle(.text)
                        Spacer()
                        HStack{
                            Text("충전하기").font(FontType.body.font)
                            Image(systemName: "chevron.right").fontWeight(.semibold)
                        }.foregroundStyle(.secondary)
                    }
                    defaultListItemView(title: "닉네임", description: vm.info.nickname)
                        .overlay { NavigationLink(value: NaviType.nickname, label: {EmptyView()}).opacity(0)}
                    defaultListItemView(title: "연락처", description: vm.info.phone)
                        .overlay { NavigationLink(value:NaviType.call,label: { EmptyView() }).opacity(0) }
                }.listRowSeparator(.hidden)
                Section {
                    defaultListItemView(title: "이메일", description: vm.info.email)
                    HStack {
                        Text("연결된 소셜 계정").font(FontType.bodyBold.font).foregroundStyle(.text)
                        Spacer()
                        HStack{
                            switch vendor {
                            case .kakao:
                                Image(.kakaoSocial)
                            case .apple:
                                Image(.appleSocial)
                            case nil:
                                EmptyView()
                            }
                        }
                    }
                    Button{
                        vm.logOutTapped.send(())
                    }label:{
                        defaultListItemView(title: "로그아웃")
                    }
                }.listRowSeparator(.hidden)
            }
            .navigationDestination(for: NaviType.self, destination: { navi in
                switch navi{
                case .call: InfoUpdateView(type:.phone).environmentObject(vm)
                case .nickname: InfoUpdateView(type:.nickname).environmentObject(vm)
                }
            })
            .scrollContentBackground(.hidden)
            .background(.gray2)
            .navigationBarTitleDisplayMode(.inline)
            .defaultNaviBack(title: "내 정보 수정", action: {
                vm.goHome.send(())
            })
            .onReceive(vm.$st, perform: { output in
                self.vendor = VendorType(rawValue: output.mySocial)
            })
        }
    }
    func defaultListItemView(title:String,description:String? = nil)-> some View{
        HStack{
            Text(title).font(FontType.bodyBold.font).foregroundStyle(.text)
            Spacer()
            if let description{
                HStack{
                    Text(description).font(FontType.body.font)
                    Image(systemName: "chevron.right").fontWeight(.semibold)
                }.foregroundStyle(.secondary)
            }
        }
    }
}
//#Preview {
//    MyProfileView(vm: MyProfileVM(ServiceProvider()), imgVM: ProfileImgVM())
//}
struct NaviModifier: ViewModifier{
    let backAction:()->()
    let title:String
    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button{
                        backAction()
                    }label: {
                        Image(systemName: "chevron.left").font(.system(size: 17,weight: .bold))
                    }.tint(.text)
                }
            })
    }
}
extension View{
    func defaultNaviBack(title:String, action: @escaping ()->()) -> some View{
        self.modifier(NaviModifier(backAction: action, title: title))
    }
}
