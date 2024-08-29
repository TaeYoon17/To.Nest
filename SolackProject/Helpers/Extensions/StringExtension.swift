//
//  StringExtension.swift
//  SolackProject
//
//  Created by 김태윤 on 1/28/24.
//

import Foundation

extension String{
    enum LabelType{
        case my
        case channel(id:Int)
        case dm(id:Int)
        var label:String{
            switch self{
            case .channel(id: let id): return "\(id)ChannelLabel"
            case .dm(id: let id): return "\(id)DMLabel"
            case .my: return "MyLabel"
            }
        }
    }
    func convertToDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        if let date = dateFormatter.date(from: self){
            return date
        }else{
            fatalError("날짜 변경 실패")
        }
    }
    func webFileToDocFile(labelType: LabelType? = nil)->String{
        let new = self.replacingOccurrences(of: "/", with: "-")
        return if let type = labelType{
            "\(type.label)\(new)"
        }else{
            new
        }
    }
    func docFileToWebFile(labelType: LabelType? = nil)->String{
        if let type = labelType{
            let new = self.replacingOccurrences(of: "\(type.label)", with: "")
            return new.replacingOccurrences(of: "-", with: "/")
        }else{
            return self.replacingOccurrences(of: "-", with: "/")
        }
    }
}
