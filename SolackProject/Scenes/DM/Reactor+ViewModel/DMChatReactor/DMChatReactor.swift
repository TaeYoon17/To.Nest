//
//  DMMSGReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
enum SendMessageType{
    case create( [DMResponse])
    case socketResponse([DMResponse])
    case dbResponse([DMResponse])
}
final class DMChatReactor:Reactor{
    @DefaultsState(\.mainWS) var mainWS
    weak var provider: ServiceProviderProtocol!
    var initialState: State = .init()
    var title:String
    var roomID:Int = 0
    var userID:Int = 0
    var chatMessage = ChatInfo(content: "", files: [])
    var chatResponse:[DMResponse] = []
    enum Action{
        case initChat
        case actionSendChat // 채팅 전송 버튼 탭
        case addImages // 이미지 추가 버튼 탭
        case setChatText(String) // 전송 메시지 텍스트 변경
        case setDeleteImage(String) // 이미지 삭제 버튼 탭
        case setSendFiles([FileData],[String]) // 포토피커에서 가져온 파일데이터 정보
    }
    enum Mutation{
        case setChatText(String)
        case prevIdentifiers([String]?)
        case setSendFiles([FileData])
        case setTitle(String)
        case appendChat(SendMessageType?)
    }
    struct State{
        var isActiveSend = false
        var title:String = ""
        var memberCount:Int = 0
        var chatText:String = ""
        var prevIdentifiers:[String]? = nil
        var sendFiles:[FileData] = []
        var sendChat:SendMessageType? = nil
    }
    init(_ provider: ServiceProviderProtocol,roomID:Int,userID:Int,title:String){
        self.provider = provider
        self.initialState = .init(title: title, memberCount: 0)
        self.roomID = roomID
        self.userID = userID
        self.title = title
    }
    deinit{
        provider.msgService.closeSocket(roomID: roomID)
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initChat:
            provider.msgService.fetchDirectMessageDB(userID: mainWS.id, roomID: roomID)
            return Observable.concat([.just(.setTitle(title))])
        case .actionSendChat:
            provider.msgService.create(roomID: self.roomID, dmChat: chatMessage)
            self.chatMessage = ChatInfo(content: "", files: [])
            return Observable.concat(.just(.setChatText("")),.just(.setSendFiles([])))
        case .addImages:
            let identifiers = chatMessage.files.map(\.name)
            return Observable.concat([
                .just(.prevIdentifiers(identifiers)).delay(.microseconds(100), scheduler: MainScheduler.asyncInstance),
                .just(.prevIdentifiers(nil))
            ])
        case .setSendFiles(let fileData,let remains):
            var newFiles = chatMessage.files.filter({remains.contains($0.name)})
            newFiles.append(contentsOf: fileData)
            chatMessage.files = newFiles
            return Observable.concat([
                .just(.setSendFiles(newFiles))
            ])
        case .setDeleteImage(let imageID):
            self.chatMessage.files.removeAll{$0.name == imageID}
            return Observable.concat([.just(.setSendFiles(chatMessage.files))])
        case .setChatText(let text):
            chatMessage.content = text
            return Observable.concat([.just(.setChatText(text))])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setChatText(let chatText):
            state.chatText = chatText
        case .prevIdentifiers(let photoIdentifiers):
            state.prevIdentifiers = photoIdentifiers
        case .setSendFiles(let sendFiles):
            state.sendFiles = sendFiles
        case .setTitle(let title):
            state.title = title
        case .appendChat(let sendMessageType):
            state.sendChat = sendMessageType
        }
        return state
    }
    func transform(state: Observable<State>) -> Observable<State> {
        return state.flatMap {[weak self] state -> Observable<State> in
            var st = state
            st.isActiveSend = !st.sendFiles.isEmpty || !st.chatText.isEmpty
            return .just(st)
        }
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        Observable.merge(mutation,messageMutation)
    }
}
