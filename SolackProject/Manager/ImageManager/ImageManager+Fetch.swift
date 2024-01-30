//
//  ImageManager+Fetch.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import Foundation
import UIKit
extension UIImage{
    enum SizeType{
        case small
        case medium
        case large
        case messageThumbnail
        var size:CGSize{
            switch self{
            case .large: .init(width: 128,height:128)
            case .small: .init(width: 44,height:44)
            case .medium: .init(width: 66,height:66)
            case .messageThumbnail: .init(width: 150, height: 120)
            }
        }
    }
}
extension UIImage{
    static func fetchBy(data:Data,type:SizeType) -> UIImage{
        IM.shared.fetchBy(data: data,size:type.size)
    }
    static func fetchBy(data: Data,size: CGSize? = nil) -> UIImage{
        IM.shared.fetchBy(data: data, size: size)
    }
    static func fetchBy(fileName:String,type:SizeType) -> UIImage{
        fetchBy(fileName: fileName,ofSize: type.size)
    }
    static func fetchBy(fileName:String,ofSize size: CGSize? = nil) -> UIImage{
        let image = IM.shared.fetchBy(fileName: fileName,size: size)
//        if let size{
//            return try! image.downSample(size: size)
//        }
        return image
    }
    // 단순 pixel 수 줄여 용량 줄이기용
    func downSample(size:CGSize) throws -> UIImage{
        guard let data = self.jpegData(compressionQuality: 1) else {
            throw Errors.compresstionFail
        }
        return IM.shared.fetchBy(data: data,size: size)
    }
    func downSample(type:SizeType) throws -> UIImage{
        try downSample(size: type.size)
    }
}
fileprivate extension IM{
    func fetchBy(data: Data,size: CGSize? = nil) -> UIImage{
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource:CGImageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOption)!
        return coreDownSample(resource: imageSource,size:size)
    }
    //MARK: -- 에러 신경쓰지 않고 있음!! - 도큐먼트에 이미지가 무조건 존재하는 경우로 한정하고 있다.
    func fetchBy(fileName:String,size:CGSize? = nil) -> UIImage{
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return UIImage()
        }
        let fileURL = documentDir.appendingPathComponent(fileName)
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource: CGImageSource = CGImageSourceCreateWithURL(fileURL as CFURL, imageSourceOption)!
        return coreDownSample(resource: imageSource,size: size)
    }
    func coreDownSample(resource:CGImageSource,size:CGSize? = nil) -> UIImage{
        let scale = UIScreen.main.scale
        let screenSize = UIScreen.main.bounds
        let maxPixel = if let size{
             max(size.width, size.height) * scale
        }else{
            max(screenSize.width,screenSize.height) * scale
        }
        let downSampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        let downSampledImage = CGImageSourceCreateThumbnailAtIndex(resource, 0, downSampleOptions)!
        return UIImage(cgImage: downSampledImage)
    }
}
