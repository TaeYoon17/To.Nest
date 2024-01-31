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
        let val = max(0,min(0.95,quality))
        let image =  img.jpegData(compressionQuality: val)
        guard var image else { throw Errors.compresstionFail }
        guard image.count > Int(1000000.0 * maxMB) else { return image }
        var (l,r):(CGFloat,CGFloat) = (0.01,1)
        var res:CGFloat = 0.5
        while l <= r{
            var mid = (l + r ) / 2
            guard let data = img.jpegData(compressionQuality: mid) else { fatalError("왜 문제야?")}
            if data.count < Int(1000000.0 * maxMB){
                res = l
                l = mid + 0.01
            }else{
                r = mid - 0.01
            }
        }
        guard let data = img.jpegData(compressionQuality: res) else {fatalError("출력 문제")}
        return data
    }
}
extension UIImage{
    func imageData(maxMB:CGFloat = 3) throws->Data{
        try ImageManager.shared.compression(self,maxMB: maxMB)
    }
}
