//
//  ImageManager+Compression.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import Foundation
import UIKit
extension ImageManager{
    fileprivate func compression(_ img:UIImage,maxMB: CGFloat = 3) throws -> Data{
        guard let data = img.jpegData(compressionQuality: 1) else { throw Errors.compresstionFail }
        let quality: CGFloat = (1000000.0 * maxMB) / CGFloat(data.count)
        let val = max(0,min(0.9,quality))
        var image =  img.jpegData(compressionQuality: val)
        guard var image else {
            throw Errors.compresstionFail
        }
        if image.count < Int(maxMB) * 1000000{
            let quality = (1000000.0 * maxMB) * val / CGFloat(image.count)
            let val = max(0,min(0.9,quality))
            var image = img.jpegData(compressionQuality: val)
            guard var image else {
                throw Errors.compresstionFail
            }
            guard image.count < Int(maxMB) * 1000000 else {
                fatalError("최대치를 넘어")
            }
            return image
        }else{
            return image
        }
    }
}
extension UIImage{
    func imageData(maxMB:CGFloat = 3) throws->Data{
        try ImageManager.shared.compression(self,maxMB: maxMB)
    }
}
