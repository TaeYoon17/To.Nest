//
//  BillResponse.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import Foundation
struct BillResponse: Codable{
    var billID: Int
    var merchantID: String
    var amount: Int // 결제 금액
    var sesacCoin: Int // 세싹 코인
    var success: Bool // 성공 여부
    var createdAt: String
    enum CodingKeys: String, CodingKey{
        case billID = "billing_id"
        case merchantID = "merchant_uid"
        case amount = "amount"
        case sesacCoin = "sesacCoin"
        case success = "success"
        case createdAt = "createdAt"
    }
}
