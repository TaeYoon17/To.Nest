//
//  CHChatReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
import ReactorKit
import RxSwift
final class CHChatReactor:Reactor{
    @DefaultsState(\.mainWS) var mainWS
    let title:String
    let channelID:Int
    var initialState: State
    var provider : ServiceProviderProtocol!
    var chatMessage = ChatInfo(content: "", files: [])
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
        case appendChatResponse([ChatResponse])
    }
    struct State{
        var isActiveSend = false
        var title:String = ""
        var memberCount:Int = 0
        var chatText:String = ""
        var prevIdentifiers:[String]? = nil
        var sendFiles:[FileData] = []
        var chatList:[ChatResponse] = []
    }
    init(_ provider: ServiceProviderProtocol,id:Int,title:String){
        self.provider = provider
        self.initialState = .init(title: title, memberCount: 0)
        self.channelID = id
        self.title = title
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initChat: return Observable.concat([ .just(.setTitle(title)) ])
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
        case .appendChatResponse(let response):
            state.chatList.append(contentsOf: response)
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let msgMutation = provider.msgService.event.flatMap { event -> Observable<Mutation> in
            switch event{
            case .create(response: let response):
                return .just(.appendChatResponse([response]))
            case .check(response: let responses):
                return .just(.appendChatResponse(responses))
//                return .just(.appendChatResponse(response))
            }
        }
        return Observable.merge([mutation,msgMutation])
    }
    func transform(state: Observable<State>) -> Observable<State> {
        return state.flatMap { state -> Observable<State> in
            var st = state
            st.isActiveSend = !st.sendFiles.isEmpty || !st.chatText.isEmpty
            return .just(st)
        }
    }
}
