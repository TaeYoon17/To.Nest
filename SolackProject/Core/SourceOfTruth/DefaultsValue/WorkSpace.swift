//
//  WorkSpace.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
struct MainWS:Codable{
    var id:Int
    var myManaging:Bool
    func updateMainWSID(id:Int,myManaging:Bool){
        @DefaultsState(\.mainWS) var mainWS
        let ws = MainWS(id: id, myManaging: myManaging)
        mainWS = ws
    }
}
extension UserDefaults{
    var mainWS:MainWS{
        get{
            guard let data = self.data(forKey: "mainWS") else {return MainWS(id: -1, myManaging: false)}
            return try! JSONDecoder().decode(MainWS.self, from: data)
        }
        set{
//            self.setValue(newValue, forKey: "mainWS")
            let data = try! JSONEncoder().encode(newValue)
            setValue(data, forKey: "mainWS")
        }
    }
    
}
