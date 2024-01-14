//
//  ICCores.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import UIKit

extension UIImage{
    static func fetchWebCache(name:String,size:CGSize? = nil) async throws -> UIImage{
        try await IMCache.shared.fetchByCache(type: .web, name: name,size: size)
    }
    static func fetchFileCache(name:String,size:CGSize? = nil) async throws -> UIImage{
        try await IMCache.shared.fetchByCache(type: .file, name: name,size:size)
    }
    static func fetchAlbumCache(name:String,size:CGSize? = nil) async throws -> UIImage{
        try await IMCache.shared.fetchByCache(type: .album, name: name,size:size)
    }
    func appendWebCache(name:String,size:CGSize? = nil,isCover:Bool = false)async throws{
        try await IMCache.shared.appendCache(type: .web, image: self, name: name,size: size,isCover: isCover)
    }
}
fileprivate extension ImageManager.Cache{
    func getKeyName(name:String,size:CGSize? = nil) -> String{
        return if let size{ "\(name)_\(Int(size.width))_\(Int(size.height))"
        }else { name }
    }
    func fetchByCache(type: IM.SourceType,name:String,size:CGSize? = nil) async throws -> UIImage{
        let keyName = getKeyName(name: name,size: size)
        if let image = memoryCache[type]?.object(forKey: keyName as NSString){
            return image
        }else if let rawImage = memoryCache[type]?.object(forKey: name as NSString){
            let downSampledImage = try rawImage.downSample(size: size!)
            try await appendCache(type: type,image:downSampledImage,name:keyName,size:size,isCover: true)
            return downSampledImage
        }
        throw Errors.cachingEmpty
    }
    //isCover: 덮어쓰기를 지원 할 것인가?
    func appendCache(type: IM.SourceType,image:UIImage,name:String,size:CGSize? = nil,isCover:Bool = false) async throws{
        let keyName = getKeyName(name: name,size: size)
        if memoryCache[type]?.object(forKey: keyName as NSString) != nil && isCover == false { return}
        await _appendCache(type: type, image: image, keyName: keyName)
    }
    func _appendCache(type: IM.SourceType,image:UIImage,keyName:String) async {
        memoryCache[type]?.setObject(image, forKey: keyName as NSString)
    }
}
