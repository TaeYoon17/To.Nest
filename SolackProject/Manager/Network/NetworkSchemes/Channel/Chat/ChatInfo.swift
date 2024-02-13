//
//  ChatInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
struct FileData:Equatable{
    let file: Data
    let type: FileType
    var name: String
    static func ==(lhs: FileData, rhs: FileData) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}
struct ChatInfo{
    var content:String
    var files:[FileData]
}
