//
//  AsyncLambda.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
extension Sequence{
    func asyncFilter(_ transform: (Element) async throws -> Bool) async rethrows -> [Element]{
        var values:[Element] = []
        for element in self{
            if try await transform(element){
                values.append(element)
            }
        }
        return values
    }
    func asyncForEach(_ transform: (Element) async throws ->Void) async rethrows{
        for element in self{ try await transform(element) }
    }
}
