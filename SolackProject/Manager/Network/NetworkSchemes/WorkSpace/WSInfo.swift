//
//  WSInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
typealias WSInfo = WorkSpaceInfo
struct WorkSpaceInfo:Codable{
    var name: String = ""
    var description:String = ""
    var image:Data? = nil
    enum CodingKeys: String,CodingKey{
        case name
        case description
        case image
    }
}
