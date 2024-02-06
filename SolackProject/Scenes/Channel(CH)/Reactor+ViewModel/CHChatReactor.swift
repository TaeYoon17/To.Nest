//
//  CHChatReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import ReactorKit
import RxSwift
extension CHChatReactor{
    enum SendChatType{
        case create( ChatResponse)
        case socketResponse(ChatResponse)
        case dbResponse([ChatResponse])
    }
}

final class CHChatReactor:Reactor{
    @DefaultsState(\.mainWS) var mainWS
    weak var provider : ServiceProviderProtocol!
    var title:String
    let channelID:Int
    var initialState: State
    
    var chatMessage = ChatInfo(content: "", files: [])
    var chatList:[ChatResponse] = []
    enum Action{
        case initChat
        case actionSendChat // 채팅 전송 버튼 탭
        case addImages // 이미지 추가 버튼 탭
        case setChatText(String) // 전송 메시지 텍스트 변경
        case setDeleteImage(String) // 이미지 삭제 버튼 탭
        case setSendFiles([FileData],[String]) // 포토피커에서 가져온 파일데이터 정보
    }
    enum Mutation{
        case setMemberCount(Int)
        case setChatText(String)
        case prevIdentifiers([String]?)
        case setSendFiles([FileData])
        case setTitle(String)
        case appendChat(SendChatType?)
    }
    struct State{
        var isActiveSend = false
        var title:String = ""
        var memberCount:Int = 0
        var chatText:String = ""
        var prevIdentifiers:[String]? = nil
        var sendFiles:[FileData] = []
        var sendChat:SendChatType? = nil
    }
    init(_ provider: ServiceProviderProtocol,id:Int,title:String){
        self.provider = provider
        self.initialState = .init(title: title, memberCount: 0)
        self.channelID = id
        self.title = title
    }
    deinit{
        provider.msgService.closeSocket(channelID: channelID)
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initChat:
        provider.msgService.fetchChannelDB(channelID: channelID,channelName: title)
        provider.chService.checkUser(channelID: channelID, title: title)
        return Observable.concat([ .just(.setTitle(title)) ])
        case .setChatText(let text):
            chatMessage.content = text
            return Observable.concat([.just(.setChatText(text))])
        case .addImages:
            let identifiers = self.chatMessage.files.map(\.name)
            return Observable.concat([
                .just(.prevIdentifiers(identifiers)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance),
                .just(.prevIdentifiers(nil))
            ])
        case .setSendFiles(let fileData,let remains):
            var newFiles = chatMessage.files.filter({ remains.contains($0.name)})
            newFiles.append(contentsOf: fileData)
            chatMessage.files = newFiles
            return Observable.concat([
                .just(.setSendFiles(newFiles))
            ])
        case .setDeleteImage(let imageID):
            self.chatMessage.files.removeAll { $0.name == imageID }
            return Observable.concat([
                .just(.setSendFiles(chatMessage.files))
            ])
        case .actionSendChat:
            provider.msgService.create(chID: self.channelID, chName: title, chat: chatMessage)
            self.chatMessage = ChatInfo(content: "", files: [])
            return Observable.concat([
                .just(.setChatText("")),
                .just(.setSendFiles([]))
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation{
        case .setMemberCount(let count):
            state.memberCount = count
        case .setChatText(let text):
            state.chatText = text
        case .prevIdentifiers(let identifiers):
            state.prevIdentifiers = identifiers
        case .setSendFiles(let fileData):
            state.sendFiles = fileData
        case .setTitle(let title):
            state.title = title
        case .appendChat(let response):
            state.sendChat = response
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let msgMutation = provider.msgService.event.flatMap {[weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            var resList: [Observable<Mutation>] = []
            switch event{
            case .create(response: let response):
                switch response{
                case .channel(let channelRes):
                    guard let res = channelRes.first else {break}
                    resList.append(contentsOf: [
                        .just(.appendChat(.create(res))).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance),
                        .just(.appendChat(nil))
                    ])
                default: break
                }
            case .check(response: let responses):
                switch responses{
                case .channel(let channels):
                    print(channels)
                    resList.append(contentsOf:[
                        .just(.appendChat(.dbResponse(channels))).throttle(.microseconds(100), scheduler: MainScheduler.asyncInstance),
                        .just(.appendChat(nil))
                    ])
                default:break
                }
            case .socketReceive(response: let response):
                switch response{
                case .channel(let channelRes):
                    guard let res = channelRes.first else {break}
                    resList.append(contentsOf: [
                        .just(.appendChat(.socketResponse(res))).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance),
                        .just(.appendChat(nil))
                    ])
                default: break
                }
            }
            return Observable.concat(resList)
        }
        let chMutation = provider.chService.event.flatMap { [weak self] event -> Observable<Mutation> in
            guard let self else {return Observable.concat([])}
            switch event{
            case .update(let response):
                guard self.channelID == response.channelID else {return Observable.concat([])}
                self.title = response.name
                return Observable.concat([
                    .just(.setTitle(response.name)),
                ])
            case .check(let response):
                guard self.channelID == response.channelID else {return Observable.concat([])}
                self.title = response.name
                return Observable.concat([
                    .just(.setTitle(response.name)),
                ])
            case .channelUsers(id: let channelID, let responses):
                guard self.channelID == channelID else {return Observable.concat([])}
                let count = responses.count
                return Observable.concat([.just(.setMemberCount(count))])
            default: return Observable.concat([])
            }
        }
        return Observable.merge([mutation,msgMutation,chMutation])
    }
    func transform(state: Observable<State>) -> Observable<State> {
        return state.flatMap { state -> Observable<State> in
            var st = state
            st.isActiveSend = !st.sendFiles.isEmpty || !st.chatText.isEmpty
            return .just(st)
        }
    }
}
