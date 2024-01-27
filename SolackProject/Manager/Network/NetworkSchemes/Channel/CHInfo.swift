//
//  CHInfo.swift
//  SolackProject
//
//  Created by 김태윤 on 1/23/24.
//

import Foundation
typealias CHInfo = ChannelInfo
struct ChannelInfo: Codable{
    var name: String = ""
    var description:String = ""
    enum CodingKeys:String,CodingKey{
        case name
        case description
    }
}
