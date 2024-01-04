//
//  DefaultStates.swift
//  lslpProject
//
//  Created by 김태윤 on 2023/11/24.
//

import Foundation
@propertyWrapper
struct DefaultsState<Value>{
    private var path: ReferenceWritableKeyPath<UserDefaults,Value>
    var wrappedValue: Value{
        get{
            UserDefaults.standard[keyPath: path]
        }
        set{
            UserDefaults.standard[keyPath: path] = newValue
        }
    }
    init(_ location:ReferenceWritableKeyPath<UserDefaults,Value>){
        self.path = location
    }
}
