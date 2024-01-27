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
    var initialState: State
    var provider : ServiceProviderProtocol!
    let channelID:Int
    var chatMessage = ChatInfo(content: "", files: [])
    let title:String
    enum Action{
        case initChat
        case setChatText(String)
        case addImages
        case setSendFiles([FileData],[String])
    }
    enum Mutation{
        case setMemberCount(Int)
        case setChatText(String)
        case prevIdentifiers([String]?)
        case setSendFiles([FileData])
        case setTitle(String)
    }
    struct State{
        var title:String = ""
        var memberCount:Int = 0
        var chatText:String = ""
        var prevIdentifiers:[String]? = nil
        var sendFiles:[FileData] = []
    }
    init(_ provider: ServiceProviderProtocol,id:Int,title:String){
        self.provider = provider
        self.initialState = .init(title: title, memberCount: 0)
        self.channelID = id
        self.title = title
        
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .initChat: return Observable.concat([
            .just(.setTitle(title))
        ])
        case .setChatText(let text): return Observable.concat([.just(.setChatText(text))])
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
            return Observable.concat([.just(.setSendFiles(newFiles))])
//        default: return  Observable.concat([])
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
        }
        return state
    }
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge([mutation])
    }
}
