//
//  ImageCache.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import UIKit
extension IM{
    enum SourceType:CaseIterable{
        case album
        case web
        case file
    }
}
typealias IMCache = IM.Cache
extension IM{
    final class Cache{
        // 메모리 캐시입니다.
        let memoryCache = SourceType.allCases.reduce(into: [:]) {
            $0[$1] = NSCache<NSString,UIImage>()
        }
        static let shared = Cache()
        // 파일(userDefaults 기반) 캐시 입니다. 추후 제작 할 수도..?
//        let fileCache = SourceType.allCases.reduce(into: [:]) {
//            $0[$1] = [String:UIImage]()
//        }
        private init(){}
        func resetCache(type: SourceType){
            memoryCache[type]?.removeAllObjects()
        }
    }
}

