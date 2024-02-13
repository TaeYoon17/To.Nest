//
//  FileType.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation
extension FileManager.FileType{
    var mimeType:String{
        switch self{
        case .gif: "image/gif"
        case .jpg: "image/jpeg"
        case .png: "image/png"
        }
    }
}
