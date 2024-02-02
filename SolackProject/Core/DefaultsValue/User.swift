//
//  User.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import Foundation
extension UserDefaults{
    var myProfile:Data?{
        get{data(forKey: "profile")}
        set{setValue(newValue, forKeyPath: "profile")}
    }
    var myInfo: MyInfo?{
        get{
            guard let data:Data = data(forKey: "myInfo") else {return nil}
            return try? JSONDecoder().decode(MyInfo.self, from: data)
        }
        set{
            let data = try? JSONEncoder().encode(newValue)
            self.setValue(data, forKey: "myInfo")
        }
    }
}
