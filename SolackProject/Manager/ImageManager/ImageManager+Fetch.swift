//
//  ImageManager+Fetch.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import Foundation
import UIKit
extension UIImage{
    static func fetchBy(data: Data,size: CGSize) -> UIImage{
        IM.shared.fetchBy(data: data, size: size)
    }
}
fileprivate extension IM{
    func fetchBy(data: Data,size: CGSize) -> UIImage{
        let scale = UIScreen.main.scale
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOption)!
        let maxPixel = max(size.width, size.height) * scale
        let downSampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        
        let downSampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions)!
        
        return UIImage(cgImage: downSampledImage)
    }
}
