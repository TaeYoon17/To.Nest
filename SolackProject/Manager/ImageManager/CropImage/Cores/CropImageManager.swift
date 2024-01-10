//
//  CropImage.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine
extension ImageManager{
    final class CropImageManager{
        static let shared = CropImageManager()
        private init(){}
    }
}

extension ImageManager.CropImageManager{
    enum ImageState {
        case empty
        case loading(Progress)
        case success(UIImage)
        case failure(Error)
    }
    enum CropType{
        case circle(CGSize)
        case rectangle(CGSize)
        var shape: any Shape{
            switch self{
            case .circle: return Circle()
            case .rectangle: return Rectangle()
            }
        }
    }
    struct ImageData: Transferable {
        let image: Data
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                return ImageData(image: data)
            }
        }
    }
    
}
