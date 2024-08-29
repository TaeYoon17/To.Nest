//
//  MyProfileVM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/30/24.
//

import Foundation
import Combine
import RxSwift
import RxCombine
import ReactorKit

final class MyProfileReactor:Reactor,ObservableObject{
    var logOutTapped = PassthroughSubject<(),Never>()
    @MainActor @DefaultsState(\.myInfo) var myInfo
    @DefaultsState(\.myProfile) var myProfile
    @MainActor @Published var st: State = .init()
    @MainActor @Published var info:MyInfo = MyInfo(userID: 0, sesacCoin: 0, email: "", nickname: "", profileImage: "", phone: "", vendor: "", createdAt: "")
    @MainActor @Published var toastType: ProfileToastType? = nil
    @MainActor var goHome = PassthroughSubject<(),Never>()
    var initialState: State = State()
    weak var provider: ServiceProviderProtocol!
    var subscription = Set<AnyCancellable>()
    var disposeBag = DisposeBag()
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
        self.state.bind(with: self) { owner, state in
            Task{@MainActor in
                owner.st = state
            }
        }.disposed(by: disposeBag)
        action.onNext(.initVM)
    }
    enum Action{
        case setNicName(String)
        case setPhone(String)
        case setImage(Data?)
        case initVM
        case setImageChanged(Bool)
        case applyNicknameUpdate
        case applyPhoneUpdate
    }
    enum Mutation{
        case setImage(Data?)
        case setNickName(String)
        case setPhone(String)
        case setEmail(String)
        case setVendor(String?)
        case setSessacCoin(Int)
        case isCompletedChanged(Bool)
        case isNickNameConvertable(Bool)
        case isPhoneConvertable(Bool)
        case profileToast(ProfileToastType?)
    }
    struct State{
        var image: Data? = nil
        var nickname:String = ""
        var phone:String = ""
        var email:String = ""
        var sessacCoin:Int = 0
        var isCompletedChanged: Bool = false
        var isNickNameConvertable: Bool = false
        var isPhoneConvertable: Bool = false
        var mySocial:String = ""
        var toast: ToastType? = nil
    }
    @MainActor func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initVM:
            guard let myInfo else {return  Observable.concat([])}
            self.info = myInfo
            provider.profileService.checkMy()
            return Observable.concat([
                .just(.setNickName(myInfo.nickname)),
                .just(.setPhone(myInfo.phone ?? "")),
                .just(.setEmail(myInfo.email)),
                .just(.setImage(myProfile)),
                .just(.setVendor(self.info.vendor))
            ])
        case .setImage(let data):
            provider.profileService.updateImage(imageData: data)
            return .just(.setImage(data))
        case .applyNicknameUpdate:
            provider.profileService.updateNickname(name: currentState.nickname)
            return Observable.concat([])
        case .applyPhoneUpdate:
            provider.profileService.updatePhone(phone: currentState.phone)
            return Observable.concat([])
        case .setNicName(let name): // 닉네임 변경하기
            let nameText = name.convertToNickName()
            return Observable.concat([
                .just(.setNickName(nameText)),
                .just(.isNickNameConvertable(!(nameText.isEmpty || nameText == myInfo?.nickname)))
            ])
        case .setPhone(let phone): // 폰 번호 변경하기
            let phoneText = phone.convertToPhoneNumber()
            return Observable.concat([
                .just(.setPhone(phoneText)),
                .just(.isPhoneConvertable(!(phoneText.isEmpty || phoneText == myInfo?.phone)))
            ])
        case .setImageChanged(let isChanged):
            self.toastType = isChanged ? .imageSuccess : .imageError
            return Observable.concat([
                .just(.profileToast(isChanged ? .imageSuccess : .imageError)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                .just(.profileToast(nil))
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setImage(let image): state.image = image
        case .setNickName(let nickname): state.nickname = nickname
        case .setPhone(let phone): state.phone = phone
        case .setEmail(let email): state.email = email
        case .isNickNameConvertable(let isAvail): state.isNickNameConvertable = isAvail
        case .isPhoneConvertable(let isAvail): state.isPhoneConvertable = isAvail
        case .isCompletedChanged(let completed): state.isCompletedChanged = completed
        case .profileToast(let toast): state.toast = toast
        case .setVendor(let vendor): state.mySocial = vendor ?? ""
        case .setSessacCoin(let coin):
            state.sessacCoin = coin
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let profileTransform = self.provider.profileService.event
            .flatMap { event -> Observable<Mutation> in
            switch event{
            case .myInfo(let info):
                Task{@MainActor in self.info = info }
                return Observable.concat([
                    .just(.setNickName(info.nickname)),
                    .just(.setPhone(info.phone ?? "")),
                    .just(.setEmail(info.email)),
                    .just(.setSessacCoin(info.sesacCoin)),
                    .just(.isCompletedChanged(true)).delay(.microseconds(200), scheduler: MainScheduler.instance),
                    .just(.isCompletedChanged(false)).delay(.microseconds(200), scheduler: MainScheduler.instance)
                ])
            case .toast(let toast):
                return Observable.concat([ .just(.profileToast(toast)) ])
            case .updatedImage:
                Task{@MainActor in
                    print("이미지 업데이트!!")
                    await self.toastType = .imageSuccess
                }
                return Observable.concat([ .just(.setImage(self.myProfile))])
            case .otherUserProfile(_):
                return Observable.concat([])
            }
        }
        let payTransform = self.provider.payService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .bill(_):
                Task{@MainActor in self.info = self.myInfo! }
            default:break
            }
            return Observable.concat([])
        }
        return Observable.merge(mutation,profileTransform,payTransform)
    }
}
extension MyProfileReactor{
    func logOut(){
        Task{
            provider.signService.signOut()
        }
        AppManager.shared.userAccessable.onNext(false)
    }
}
