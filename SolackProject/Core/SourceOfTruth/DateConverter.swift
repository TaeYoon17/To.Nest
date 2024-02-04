//
//  DateConverter.swift
//  SolackProject
//
//  Created by 김태윤 on 2/4/24.
//

import Foundation
extension Date{
    func msgDateConverter() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)

        if let currentDate = calendar.date(from: components) {
            let now = Date()
            
            if calendar.isDate(currentDate, inSameDayAs: now) {
                // 같은 날짜일 경우
                dateFormatter.dateFormat = "hh:mm a"
                return dateFormatter.string(from: self)
            } else {
                // 다른 날짜일 경우
                dateFormatter.dateFormat = "M/d hh:mm a"
                return dateFormatter.string(from: self)
            }
        }

        return ""
    }
}
