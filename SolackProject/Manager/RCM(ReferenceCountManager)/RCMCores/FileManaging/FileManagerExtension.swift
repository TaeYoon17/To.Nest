//
//  FileManager.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
// ReferenceCount에 의해 관리되는 로컬 파일들 CRUD를 돕는 익스텐션
typealias FileType = FileManager.FileType
extension FileManager{
    enum FileType:String{
        case jpg
        case png
        case gif
    }
    static func checkExistDocument(fileName:String,type:FileType)->Bool{
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return false}
        let fileURL = documentDir.appendingPathComponent("\(fileName).\(type)")
        return FileManager.default.fileExists(atPath: fileURL.path())
    }
    static func removeFromDocument(fileName:String,type:FileType){
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let fileURL = documentDir.appendingPathComponent("\(fileName).\(type)")
        do{
            try FileManager.default.removeItem(at: fileURL)
        }catch{
            print(error)
        }
    }
}
