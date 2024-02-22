//
//  HomeReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/14/24.
//

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
enum HomePresent:Equatable{
    case create
    case explore
    case chatting(chID:Int,chName:String)
    case invite
    case dmExplore
    case dm(roomID:Int,user:UserResponse)
}
final class HomeReactor: Reactor{
    let initialState: State = .init()
    weak var provider: ServiceProviderProtocol!
    @DefaultsState(\.mainWS) var mainWS
    enum Action{
        case setPresent(HomePresent?)
        case setMainWS(wsID:String)
        case initMainWS
        case updateUnreads
    }
    enum Mutation{
        case channelDialog(HomePresent?)
        case isMasking(Bool)
        case wsTitle(String)
        case wsLogo(String)
        case setChannelUnreads([UnreadsChannelRes]?)
        case setChannelList([CHResponse]?)
        case setDMUnreads([UnreadDMRes]?)
        case setDMList([DMRoomResponse]?)
        case isProfileUpdated(Bool)
        case setToast(ToastType?)
        case setLoading(Bool)
    }
    struct State{
        var channelDialog:HomePresent? = nil
        var isMasking: Bool? = nil
        var channelList:[CHResponse]? = nil
        var channelUnreads:[UnreadsChannelRes]? = nil
        var dmList:[DMRoomResponse]? = nil
        var dmUnreads:[UnreadDMRes]? = nil
        var wsTitle:String = ""
        var wsLogo: String = ""
        var isProfileUpdated:Bool = false
        var toast:ToastType? = nil
        var isLoading:Bool = false
    }
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .setPresent(let present):
            switch present{
                case .chatting(chID: let id, chName: let name):
                let unreads = UnreadsChannelRes(channelID: id, name: name, count: 0)
                return Observable.concat([
//                    .just(.setChannelUnreads([unreads])),
                    Observable.just(.channelDialog(present)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                    Observable.just(.channelDialog(nil)).delay(.milliseconds(100), scheduler: MainScheduler.instance)
                ])
            case .invite:
                if !mainWS.myManaging{
                    return Observable.concat([
                        .just(.setToast(WSToastType.inviteNotManager)).delay(.microseconds(100), scheduler: MainScheduler.instance),
                        .just(.setToast(nil))
                    ])
                }
                default:break
            }
            return Observable.concat([
                Observable.just(.channelDialog(present)).delay(.milliseconds(100), scheduler: MainScheduler.instance),
                Observable.just(.channelDialog(nil)).delay(.milliseconds(100), scheduler: MainScheduler.instance)
            ])
        case .setMainWS(wsID: let wsID):
            provider.wsService.setHomeWS(wsID: Int(wsID)!)
            return Observable.concat([.just(.setLoading(true)).delay(.microseconds(100), scheduler: MainScheduler.instance)])
        case .initMainWS:
            provider.wsService.initHome()
            return Observable.concat([])
        case .updateUnreads:
            provider.chService.checkAllMy()
            provider.dmService.checkAll(wsID: mainWS.id)
            return Observable.concat([])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .channelDialog(let present):
            state.channelDialog = present
        case .setChannelList(let list):
            state.channelList = list
        case .isMasking(let isMasking):
            state.isMasking = isMasking
        case .wsLogo(let logo):
            state.wsLogo = logo
        case .wsTitle(let title):
            state.wsTitle = title
        case .setChannelUnreads(let responses):
            state.channelUnreads = responses
        case .isProfileUpdated(let update):
            state.isProfileUpdated = update
        case .setToast(let toast):
            state.toast = toast
        case .setDMUnreads(let unreads):
            state.dmUnreads = unreads
        case .setDMList(let dmList):
            state.dmList = dmList
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let wsService = wsMutationTransform
        let chService = chMutationTransform
        let dmService = dmMutationTransform
        let profileService = profileMutationTransform
        let msgService = messageMutationTransform
        return Observable.merge(mutation,wsService,chService,dmService,profileService,msgService)
    }
}
