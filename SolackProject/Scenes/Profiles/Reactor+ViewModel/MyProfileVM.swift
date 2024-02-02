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
//enum SocialType:String{
//    case kakao = "kakao"
//    case apple = "apple"
//}
final class MyProfileReactor:Reactor,ObservableObject{
    @MainActor @DefaultsState(\.myInfo) var myInfo
    @DefaultsState(\.myProfile) var myProfile
    @MainActor @Published var st: State = .init()
    @MainActor @Published var info:MyInfo = MyInfo(userID: 0, email: "", nickname: "", profileImage: "", phone: "", vendor: "", createdAt: "")
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
        case applyNicknameUpdate
        case applyPhoneUpdate
    }
    enum Mutation{
        case setImage(Data?)
        case setNickName(String)
        case setPhone(String)
        case setEmail(String)
        case setVendor(String?)
        case isCompletedChanged(Bool)
        case isNickNameConvertable(Bool)
        case isPhoneConvertable(Bool)
        case profileToast(MyProfileToastType?)
    }
    struct State{
        var image: Data? = nil
        var nickname:String = ""
        var phone:String = ""
        var email:String = ""
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
            print(self.info.vendor)
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
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setImage(let image):
            state.image = image
        case .setNickName(let nickname): state.nickname = nickname
        case .setPhone(let phone): state.phone = phone
        case .setEmail(let email): state.email = email
        case .isNickNameConvertable(let isAvail): state.isNickNameConvertable = isAvail
        case .isPhoneConvertable(let isAvail): state.isPhoneConvertable = isAvail
        case .isCompletedChanged(let completed): state.isCompletedChanged = completed
        case .profileToast(let toast): state.toast = toast
        case .setVendor(let vendor): state.mySocial = vendor ?? ""
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
                    .just(.isCompletedChanged(true)).delay(.microseconds(200), scheduler: MainScheduler.instance),
                    .just(.isCompletedChanged(false)).delay(.microseconds(200), scheduler: MainScheduler.instance)
                ])
            case .toast(let toast):
                return Observable.concat([ .just(.profileToast(toast)) ])
            case .updatedImage:
                return Observable.concat([ .just(.setImage(self.myProfile))])
            }
        }
        return Observable.merge(mutation,profileTransform)
    }
}


final class MyProfileVM: ObservableObject{
    var provider:ServiceProviderProtocol!
    @MainActor var goHome = PassthroughSubject<(),Never>()
    @MainActor @DefaultsState(\.myInfo) var myInfo
    @DefaultsState(\.myProfile) var myProfile
    @MainActor @Published var state = State()
    @MainActor @Published var info:MyInfo = MyInfo(userID: 0, email: "", nickname: "", profileImage: "", phone: "", vendor: "", createdAt: "")
    @MainActor var action = PassthroughSubject<Action,Never>()
    
    var subscription = Set<AnyCancellable>()
    var disposeBag = DisposeBag()
    private var currentState = State()
    
    enum Action{
        case setNicName(String)
        case setPhone(String)
        case setImage(Data?)
        case initVM
        case applyNicknameUpdate
        case applyPhoneUpdate
    }
    enum Mutation{
        case setImage(Data?)
        case setNickName(String)
        case setPhone(String)
        case setEmail(String)
        case isCompletedChanged(Bool)
        case isNickNameConvertable(Bool)
        case isPhoneConvertable(Bool)
        case profileToast(MyProfileToastType?)
    }
    struct State{
        var image: Data? = nil
        var nickname:String = ""
        var phone:String = ""
        var email:String = ""
        var isCompletedChanged: Bool = false
        var isNickNameConvertable: Bool = false
        var isPhoneConvertable: Bool = false
        var toast: ToastType? = nil
    }
    init(_ provider:ServiceProviderProtocol){
        self.provider = provider
        Task{@MainActor in
            let actionMutation = self.action.flatMap {[weak self] action -> AnyPublisher<Mutation,Never> in
                guard let self else {fatalError("있을 수 없어") }
                return self.mutate(action: action)
            }.eraseToAnyPublisher()
            let transformMutation = self.transform(mutation: actionMutation).eraseToAnyPublisher()
            transformMutation.receive(on: RunLoop.main).sink {[weak self] mutation in
                guard let self else {return}
                let newState = self.reduce(state: self.currentState,mutation: mutation)
                self.currentState = newState
                self.state = newState
            }.store(in: &subscription)
            action.send(.initVM)
        }
    }
    
    @MainActor func mutate(action: Action) -> AnyPublisher<Mutation,Never>{
        switch action {
        case .initVM:
            guard let myInfo else {return  Empty<Mutation, Never>().eraseToAnyPublisher()}
            self.info = myInfo
            return .init(Just(.setNickName(myInfo.nickname))
                .append(.setPhone(myInfo.phone ?? ""))
                .append(.setEmail(myInfo.email))
                .append(.setImage(myProfile))
            )
            
        case .setImage(let data):
            provider.profileService.updateImage(imageData: data)
            return .init(Just(.setImage(data)))
        case .applyNicknameUpdate:
            provider.profileService.updateNickname(name: currentState.nickname)
            return  Empty<Mutation, Never>().eraseToAnyPublisher()
        case .applyPhoneUpdate:
            provider.profileService.updatePhone(phone: currentState.phone)
            return Empty<Mutation, Never>().eraseToAnyPublisher()
        case .setNicName(let name): // 닉네임 변경하기
            let nameText = name.convertToNickName()
            if nameText.isEmpty || nameText == myInfo?.nickname{
                return .init(Just(.setNickName(nameText)).append(.isNickNameConvertable(false)))
            }
            return .init(Just(.setNickName(nameText)).append(.isNickNameConvertable(true)))
        case .setPhone(let phone): // 폰 번호 변경하기
            let phoneText = phone.convertToPhoneNumber()
            if phoneText.isEmpty || phoneText == myInfo?.phone{
                return .init(Just(.setPhone(phoneText)).append(.isPhoneConvertable(false)))
            }
            return .init(Just(.setPhone(phoneText)).append(.isPhoneConvertable(true)))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setImage(let image):
            state.image = image
        case .setNickName(let nickname):
            state.nickname = nickname
        case .setPhone(let phone):
            state.phone = phone
        case .setEmail(let email):
            state.email = email
        case .isNickNameConvertable(let isAvail):
            state.isNickNameConvertable = isAvail
        case .isPhoneConvertable(let isAvail):
            state.isPhoneConvertable = isAvail
        case .isCompletedChanged(let completed):
            print("여기 반응",completed)
            state.isCompletedChanged = completed
        case .profileToast(let toast):
            state.toast = toast
        }
        return state
    }
    func transform(mutation: AnyPublisher<Mutation,Never>) -> AnyPublisher<Mutation,Never>{
        let combinePublisher = self.provider.profileService.event.asPublisher().assertNoFailure()
        let profilePublisher = combinePublisher.flatMap {[weak self] event -> AnyPublisher<Mutation,Never> in
            guard let self else {fatalError("이게 말이 안됨...")}
            switch event{
            case .myInfo(let info):
                Task{@MainActor in self.info = info }
                return .init(
                    Just(.setNickName(info.nickname))
                    .append(.setPhone(info.phone ?? ""))
                    .append(.setEmail(info.email))
                    .append(.setImage(myProfile))
                    .append(Just(Mutation.isCompletedChanged(true)).delay(for: .seconds(0.2), scheduler: RunLoop.main))
                    .append(Just(Mutation.isCompletedChanged(false)).delay(for: .seconds(1), scheduler: RunLoop.main))
                    )
            case .toast(let toast):
                return .init(Just(Mutation.profileToast(toast)))
            case .updatedImage:
                return .init(Just(Mutation.setImage(self.myProfile)))
            }
        }.eraseToAnyPublisher()
        return Publishers.Merge(mutation, profilePublisher).eraseToAnyPublisher()
    }
}
extension MyProfileVM{
    var emptyPublisher:AnyPublisher<Mutation,Never>{
        Empty<Mutation, Never>().eraseToAnyPublisher()
    }
}
// MARK: -- 오류 원인...
//            .map { mutation -> State in
//                print("mutation이 발생한다.")
//                self.currentState = self.reduce(state: self.currentState, mutation: mutation)
//                return self.currentState
//            }.sink { [weak self] state in
//                self?.state = state
//            }.store(in: &subscription)
