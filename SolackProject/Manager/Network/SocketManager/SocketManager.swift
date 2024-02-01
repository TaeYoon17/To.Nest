//
//  SocketManager.swift
//  SolackProject
//
//  Created by 김태윤 on 2/1/24.
//

import Foundation
import RxSwift
import Alamofire
import SocketIO
protocol SocketReceivable:AnyObject{
    func receivedSocketData(result: Result<Data,Error>,channelID:Int)
}
typealias SocketManagerr = NetworkManager.SocketManagerr
extension NetworkManager{
    final class SocketManagerr: NSObject{
        @DefaultsState(\.accessToken) var accessToken
        static let shared = SocketManagerr()
        private var timer:Timer? // 핑 생성용
        var socket: SocketIOClient!
        private var isOpen = false
        private override init(){ super.init() }
        let chatResponsesPublish = PublishSubject<[ChatResponse]>()
        var channelID:Int!
        weak var delegate: (any SocketReceivable)?
        var manager: SocketManager!
        func openChatSocket(channelID:Int,delegate:SocketReceivable) throws {
            self.delegate = delegate
            self.channelID = channelID
            let socketStr = API.chatSocketURL+"/ws-channel-\(channelID)"
            if let url = URL(string:socketStr){
                self.manager = SocketManager(socketURL: url)
                socket = self.manager.socket(forNamespace: "/")
                socket.connect()
                socket.on(clientEvent:.connect) {[weak self] data, ack in
                    print("SOCKET IS CONNECTED", data, ack)
                    self?.isOpen = true
                }
                ping()
                socket.on("channel") {[weak self] dataArray, ack in
                    print("CHANNEL RECEIVED", dataArray, ack)
                    guard let self,self.isOpen else {return}
                    guard let data = dataArray[0] as? Data else {fatalError("데이터 가져오기 오류" )}
                    if let channelID = self.channelID{
                        self.delegate?.receivedSocketData(result: .success(data),channelID: channelID)
                    }
                }
            }
        }
        func closeChatSocket(channelID: Int){
            guard channelID == self.channelID else {return}
            print("소켓을 닫는다...")
            self.channelID = nil
            self.delegate = nil
            socket.on(clientEvent: .disconnect) {[weak self] data, ack in
                guard let self else {return}
                print("SOCKET IS DISCONNECTED", data, ack)
                self.isOpen = false
                self.socket = nil
            }
            timer?.invalidate()
            timer = nil
            isOpen = false
        }
        //        private func receive(data: Data){
        //            if isOpen{
        //                webSocket?.receive(completionHandler: { [weak self] result in
        //                    switch result{
        //                    case .success(let success):
        //                        switch success{
        //                        case .data(let data):
        //                            if let channelID = self?.channelID{
        //                                self?.delegate?.receivedSocketData(result: .success(data),channelID: channelID)
        //                            }
        //                        case .string(let str): print(str)
        //                        @unknown default: print("Unknown values")
        //                        }
        //                    case .failure(let failure):
        //                        print("Websocket receive failed")
        //                        print(failure)
        //                        if let channelID = self?.channelID{
        //                            self?.delegate?.receivedSocketData(result: .failure(failure),channelID: channelID)
        //                        }
        //                        self?.closeChatSocket(channelID: self!.channelID)
        //                    }
        //                    self?.receive()
        //                })
        //            }
        //        }
        private func ping(){
            print("핑 생성생성")
            Task{@MainActor in
                self.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { [weak self] _ in // 5초마다 반복적으로 실행
                    self?.socket.on(clientEvent: .ping, callback: { data, ack in
                        print("SOCKET IS PING", data, ack)
                    })
                })
            }
        }
    }
}
//extension NetworkManager.SocketManagerr:URLSessionWebSocketDelegate{
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
//        print("WebSocket OPEN")
//        isOpen = true
//        receive()
//    }
//    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
//        isOpen = false
//        print("WebSocket CLOSE")
//    }
//}
