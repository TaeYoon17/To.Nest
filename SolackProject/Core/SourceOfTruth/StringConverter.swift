//
//  StringConverter.swift
//  SolackProject
//
//  Created by 김태윤 on 2/4/24.
//

import Foundation
extension String{
    func convertToNickName()->String{
        guard self.count < 31 else {
            return String(self[startIndex..<index(startIndex, offsetBy: 31)])
        }
        return self
    }
    func convertToPhoneNumber()->String{
        guard self.count < 13 else {
            return String(self[startIndex..<index(startIndex, offsetBy: 13)])
        }
        var origin = self
        if let last = origin.last, last == "-"{
            _ = origin.popLast()
            return origin
        }
        origin = origin.replacingOccurrences(of: "-", with: "")
        var newOrigin = ""
        for i in 0..<origin.count{
            if i == 3 || i == 7{ newOrigin += "-" }
            newOrigin.append(origin[origin.index(origin.startIndex, offsetBy: i)])
        }
        return newOrigin
    }
}
