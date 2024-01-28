//
//  URCMTable.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
import RealmSwift

final class UserRCMTable: Object,RCMTableAble{
    @Persisted(primaryKey: true) var name: String
    @Persisted var count: Int = 0
    @Persisted var userID:Int
    @Persisted var channelID:Int
    
    required convenience init(name: String, count: Int) {
        self.init()
        let names = name.split(separator: "__").map{Int($0)!}
        self.name = name
        self.count = count
        self.channelID = names[0]
        self.userID = names[1]
    }
    convenience init(channelID:Int,userID:Int) {
        self.init()
        self.count = count
        self.channelID = channelID
        self.userID = userID
        self.name = idConverter(channelID: channelID, userID: userID)
    }
    private func idConverter(channelID: Int,userID:Int) -> String{
        "\(channelID)__\(userID)"
    }
}
