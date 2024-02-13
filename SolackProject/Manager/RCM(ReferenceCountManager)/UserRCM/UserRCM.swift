//
//  UserRCM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
import RealmSwift
struct UserItem: RCMTableConvertable{
    var name: String{ "\(channelID)__\(userID)" }
    var channelID:Int
    var userID:Int
    var count: Int
    
    init(channelID:Int,userID:Int,count:Int){
        self.channelID = channelID
        self.userID = userID
        self.count = count
    }
    init(name: String, count: Int) {
        let names = name.split(separator: "__").map{Int($0)}
        channelID = names[0]!
        userID = names[1]!
        self.count = count
    }
}
typealias URCM = UserRCM

final class UserRCM: RCMAble{
    typealias Item = UserItem
    typealias Table = UserRCMTable
    
    @BackgroundActor var repository: ReferenceRepository<UserRCMTable>!
    private var userRepository: UIRepository!
    static let shared = UserRCM()
    var instance: [String : UserItem] = [:]
    private init(){
        Task{@BackgroundActor in
            self.repository = try await ReferenceRepository<UserRCMTable>()
            self.userRepository = try await UIRepository()
            await self.resetInstance()
        }
    }
    
    @BackgroundActor private func resetInstance() async {
        let res = repository.getAllTable().reduce(into: [:]) {
            $0[$1.id] = UserItem(name: $1.name, count: $1.count)
        }
        self.instance = res
    }
    
    func plusCount(id: String) async {
        if instance[id] == nil{
            instance[id] = UserItem(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    
    func minusCount(id: String) async {
        instance[id]?.count -= 1
    }
    
    func saveRepository() async {
        for (k,v) in instance{
            await self.repository.insert(item: v)
        }
        await repository.clearChannelChatUserTable(userRepository: userRepository)
        await resetInstance()
    }
    
    var snapshot: SnapShot{
        SnapShot(irc: self)
    }
    
    func apply(_ snapshot: SnapShot) {
        instance = snapshot.instance
    }
}
extension RCMSnapshot<UserRCM, UserItem, UserRCMTable>{
    private func idConverter(messageID: Int,userID:Int) -> String{
        "\(messageID)__\(userID)"
    }
    func existItem(channelID: Int,userID:Int) -> Bool{
        let id = idConverter(messageID: channelID, userID: userID)
        return instance[id] != nil
    }
    func existItem(roomID: Int,userID:Int) -> Bool{
        let id = idConverter(messageID: roomID, userID: userID)
        return instance[id] != nil
    }
    mutating func plusCount(channelID: Int,userID:Int) async{
        let id = idConverter(messageID: channelID, userID: userID)
        if instance[id] == nil{
            instance[id] = Item(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    mutating func plucCount(roomID:Int, userID:Int) async{
        let id = idConverter(messageID: -roomID, userID: userID)
        if instance[id] == nil{
            instance[id] = Item(name: id, count: 1)
        }else{
            instance[id]?.count += 1
        }
    }
    mutating func minusCount(channelID:Int, userID:Int)async {
        let id = idConverter(messageID: channelID, userID: userID)
        instance[id]?.count -= 1
    }
    mutating func minusCount(roomID:Int, userID:Int)async {
        let id = idConverter(messageID: -roomID, userID: userID)
        instance[id]?.count -= 1
    }
}

fileprivate extension ReferenceRepository where T: UserRCMTable{
    func clearChannelChatUserTable(userRepository: UIRepository) async {
        let emptyTables:Results<T> = self.getTasks.where{ $0.count <= 0 }
        if emptyTables.isEmpty { return }
        let emptyUsers = Set(emptyTables.map{$0.userID}) // 채팅방에서 삭제할 대상의 유저 정보
        // 채널 채팅에서 없앨 유저 정보
        try! await realm.asyncWrite {
            realm.delete(emptyTables)
        }
        let allURCMTable = self.getTasks // 삭제 후 전체 채팅 유저 테이블을 가져온다.
        let deleteTargetUserIDs:Set<Int> = emptyUsers.filter { userID in
            // 삭제한 유저 정보를 담는 전체 채팅 유저 테이블
            let sameUserIDTables = allURCMTable.where { $0.userID == userID }
            // 전체 채팅 유저 테이블 중 같은 채팅 유저 정보가 없다 -> 유저 테이블에서도 삭제하면 된다.
            return sameUserIDTables.isEmpty
        }
        await userRepository.deleteUserIDs(Array(deleteTargetUserIDs))
    }
}
