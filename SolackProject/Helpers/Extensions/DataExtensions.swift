//
//  DataExtensions.swift
//  SolackProject
//
//  Created by 김태윤 on 1/29/24.
//

import Foundation
extension Data{
    func saveToDocument(fileName:String) throws{
        //1. 도큐먼트 경로 찾기
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDir.appendingPathComponent(fileName)
        try self.write(to: fileURL)
    }
}
