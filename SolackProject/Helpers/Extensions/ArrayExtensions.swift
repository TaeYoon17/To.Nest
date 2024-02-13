//
//  ArrayExtensions.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
extension Array where Element: Hashable{
    func makeSet()->Set<Element> { Set(self) }
}
