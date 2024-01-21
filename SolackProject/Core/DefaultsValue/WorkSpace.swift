//
//  WorkSpace.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
extension UserDefaults{
    var mainWS:Int{
        get{
            self.integer(forKey: "mainWS")
        }
        set{
            self.setValue(newValue, forKey: "mainWS")
        }
    }
}
