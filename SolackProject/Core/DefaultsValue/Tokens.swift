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
}
