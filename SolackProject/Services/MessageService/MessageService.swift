//
//  ChatService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/27/24.
//

import Foundation
import RxSwift
import UIKit
typealias MSGService = MessageService
protocol MessageProtocol{
    var event:PublishSubject<MSGService.Event> {get}
    // 채널
    func getChannelDatas(chID:Int,chName:String)
    func fetchChannelDB(channelID:Int,channelName:String)
    func create(chID:Int,chName:String,chat: ChatInfo)
    func openSocket(channelID: Int)
    func closeSocket(channelID: Int)
    // DM
    func getDirectMessageDatas(roomID:Int,userID:Int)
    func fetchDirectMessageDB(userID:Int,roomID: Int)
    func create(roomID: Int,dmChat: ChatInfo)
    func openSocket(roomID:Int)
    func closeSocket(roomID:Int)
}
final class MessageService:MessageProtocol{
    @DefaultsState(\.mainWS) var mainWS
    @DefaultsState(\.userID) var userID
    var event = PublishSubject<MSGService.Event>()
    @BackgroundActor var channelRepostory: ChannelRepository!
    @BackgroundActor var chChatrepository: ChannelChatRepository!
    @BackgroundActor var roomRepository: DMRoomRepository!
    @BackgroundActor var dmChatRepository: DMChatRepository!
    @BackgroundActor var userRepository: UserInfoRepository!
    @BackgroundActor var imageReferenceCountManager: ImageRCM!
    @BackgroundActor var userReferenceCountManager: UserRCM!
    var taskCounter:TaskCounter = .init()
    init(){
        Task{@BackgroundActor in
            channelRepostory = try await ChannelRepository()
            chChatrepository = try await ChannelChatRepository()
            userRepository = try await UserInfoRepository()
            roomRepository = try await DMRoomRepository()
            dmChatRepository = try await DMChatRepository()
            imageReferenceCountManager = ImageRCM.shared
            userReferenceCountManager = UserRCM.shared
        }
    }
    enum MSGResponse{
        case dm([DMResponse])
        case channel([ChatResponse])
    }
    enum Event{
        case create(response:MSGResponse)
        case check(response:MSGResponse)
        case socketReceive(response:MSGResponse)
    }
}


