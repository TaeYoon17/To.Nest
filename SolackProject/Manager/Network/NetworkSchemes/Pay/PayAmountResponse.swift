//
//  PayAmountResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import Foundation
struct PayAmountResponse:Codable,Identifiable,Equatable{
    var id: String{item}
    var item:String
    var amount:String
    enum CodingKeys: String, CodingKey{
        case item
        case amount
    }
}
