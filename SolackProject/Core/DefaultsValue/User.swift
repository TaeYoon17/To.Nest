//
//  User.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
extension UserDefaults{
    var nickname:String{
        get{self.string(forKey: "nickname") ?? "" }
        set{
            setValue(newValue, forKey: "nickname")
        }
    }
    var phoneNumber:String?{
        get{ self.string(forKey: "phoneNumber") }
        set{ setValue(newValue,forKey: "phoneNumber") }
    }
    var profile:Data?{
        get{data(forKey: "profile")}
        set{setValue(newValue, forKeyPath: "profile")}
    }
    var email:String{
        get{string(forKey: "email") ?? ""}
        set{setValue(newValue, forKey: "email")}
    }
}
