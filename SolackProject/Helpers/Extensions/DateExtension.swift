//
//  DateExtension.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
extension Date{
    func convertToString()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
extension Date{
    static var nowKorDate:Date{
        let currentDate = Date()
        // 9시간을 초 단위로 계산하여 추가
        let newDate = currentDate.addingTimeInterval(9 * 3600)
        return newDate
    }
}
