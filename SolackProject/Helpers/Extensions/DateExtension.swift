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
        dateFormatter.timeZone = .current
        
        let dateString = dateFormatter.string(from: self.addingTimeInterval(-9 * 3600))
        return dateString
    }
}
extension Date{
    static var nowKorDate:Date{
        let currentDate = Date()
        // 9시간을 초 단위로 계산하여 추가, 안읽은 메시지 계수 문제로 1초 추가
        let newDate = currentDate.addingTimeInterval(9 * 3600 + 1)
        return newDate
    }
}
extension Date{
    func msgDateConverter() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self.addingTimeInterval(-9 * 3600))
        if let currentDate = calendar.date(from: components) {
            let now = Date()
            
            if calendar.isDate(currentDate, inSameDayAs: now) {
                // 같은 날짜일 경우
                dateFormatter.dateFormat = "hh:mm a"
                return dateFormatter.string(from: currentDate)
            } else {
                // 다른 날짜일 경우
                dateFormatter.dateFormat = "M/d hh:mm a"
                return dateFormatter.string(from: currentDate)
            }
        }

        return ""
    }
    func wsDateConverter()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy.MM.dd"
        let date = Date()
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
}
