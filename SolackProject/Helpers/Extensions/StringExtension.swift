//
//  StringExtension.swift
//  SolackProject
//
//  Created by 김태윤 on 1/28/24.
//

import Foundation

extension String{
    func convertToDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: self){
            return date
        }else{
            fatalError("날짜 변경 실패")
        }
    }
    func webFileToDocFile()->String{
        self.replacingOccurrences(of: "/", with: "_")
    }
}
