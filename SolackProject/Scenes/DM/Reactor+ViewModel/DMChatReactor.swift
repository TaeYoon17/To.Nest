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
    case create( ChatResponse)
    case socketResponse(ChatResponse)
    case dbResponse([ChatResponse])
}

final class DMChatReactor:Reactor{
    @DefaultsState(\.mainWS) var mainWS
    weak var provider: ServiceProviderProtocol!
    var initialState: State = .init()
    var title:String
    var roomID:Int? = nil
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
        case setMemberCount(Int)
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
    init(_ provider: ServiceProviderProtocol,id:Int,title:String){
        self.provider = provider
        self.initialState = .init(title: title, memberCount: 0)
        self.roomID = id
        self.title = title
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initChat:
            if let roomID{
                provider.msgService.fetchDirectMessageDB(roomID: roomID)
            }
            return Observable.concat([.just(.setTitle(title))])
        case .actionSendChat:
//            provider.msgService.create
            return Observable.concat([])
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
}
