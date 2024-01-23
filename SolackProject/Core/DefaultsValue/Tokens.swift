//
//  DeviceToken.swift
//  SolackProject
//
//  Created by 김태윤 on 1/4/24.
//

import Foundation
extension UserDefaults{
    var deviceToken:String{
        get{
            self.string(forKey: "deviceToken") ?? ""
        }
        set{
            setValue(newValue, forKey: "deviceToken")
        }
    }
    var accessToken:String{
        get{
            self.string(forKey: "accessToken") ?? ""
        }
        set{
            setValue(newValue, forKey: "accessToken")
        }
    }
    var refreshToken:String{
        get{
            self.string(forKey: "refreshToken") ?? ""
            
        }
        set{
            setValue(newValue, forKey: "refreshToken")
        }
    }
    var expiration: Date?{
        get{
            let dateString = self.string(forKey: "expiration") ?? ""
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let date = formatter.date(from: dateString)
            return date
        }
        set{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let newValue{
                let dateStr = formatter.string(from: newValue)
                setValue(dateStr,forKey: "expiration")
            }
        }
    }
    var userID: Int{
        get{ integer(forKey: "userNumber") }
        set{ setValue(newValue,forKey: "userNumber") }
    }
    var appleID: String?{
        get{ string(forKey: "appleID")}
        set{ setValue(newValue,forKey: "appleID") }
    }
}
