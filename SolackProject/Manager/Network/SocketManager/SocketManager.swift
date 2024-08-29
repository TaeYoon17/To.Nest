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
    func receivedSocketData(result:Result<Data,Error>,roomID:Int)
}
typealias SocketManagerr = NetworkManager.SocketManagerr
extension NetworkManager{
    final class SocketManagerr: NSObject{
        enum ConnectType{
            case dm( roomID:Int)
            case chat(channelID:Int)
            var name:String{
                switch self{
                case .chat: "channel"
                case .dm:"dm"
                }
            }
        }
        @DefaultsState(\.accessToken) var accessToken
        static let shared = SocketManagerr()
        private var timer:Timer? // 핑 생성용
        private let socketURL = URL(string: API.socketURL)!
        private var isOpen = false
        private override init(){ super.init() }
        var channelID:Int!
        var roomID:Int!
        weak var delegate: (any SocketReceivable)?
        var socket: SocketIOClient!
        var manager: SocketManager!
        func openSocket(connect: ConnectType,delegate: SocketReceivable) throws{
            self.delegate = delegate
            self.manager = SocketManager(socketURL: socketURL)
            switch connect{
            case .chat(let id): 
                self.channelID = id
                socket = self.manager.socket(forNamespace: "/ws-channel-\(id)")
            case .dm(let id):
                self.roomID = id
                socket = self.manager.socket(forNamespace: "/ws-dm-\(id)")
            }
            socket.on(clientEvent:.connect) {[weak self] data, ack in
                print("SOCKET IS CONNECTED", data, ack)
                self?.isOpen = true
            }
            ping()
            socket.on(connect.name) {[weak self] dataArray, ack in
                print("CHANNEL RECEIVED", dataArray, ack)
                guard let self,self.isOpen else {return}
                guard let jsonDict = dataArray[0] as? [String:Any] else {fatalError("데이터 가져오기 오류" )}
                guard let data = try? JSONSerialization.data(withJSONObject: jsonDict) else {fatalError("데이터 가져오기 오류" )}
                switch connect{
                case .chat(channelID: let channelID):
                    self.delegate?.receivedSocketData(result: .success(data),channelID: channelID)
                case .dm(roomID: let dmID):
                    self.delegate?.receivedSocketData(result: .success(data), roomID: dmID)
                }
            }
            socket.connect()
        }
        func closeChatSocket(){
            print("소켓을 닫는다...")
            socket.on(clientEvent: .disconnect) {[weak self] data, ack in
                print("SOCKET IS DISCONNECTED", data, ack)
                guard let self else {return}
                print("SOCKET IS DISCONNECTED", data, ack)
                self.isOpen = false
                self.socket = nil
                self.channelID = nil
                self.roomID = nil
                self.delegate = nil
                timer?.invalidate()
                timer = nil
            }
            Task{
                try await Task.sleep(for: .seconds(3))
                print("소켓 강제종료")
                self.channelID = nil
                self.roomID = nil
                self.delegate = nil
                isOpen = false
                self.delegate = nil
                timer?.invalidate()
                timer = nil
            }
        }
        private func ping(){
            Task{@MainActor [weak self] in
                self?.timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { [weak self] _ in // 10초마다 반복적으로 실행
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
