//
//  ItemProvider.swift
//  SolackProject
//
//  Created by 김태윤 on 1/26/24.
//
import UIKit
import Photos
import PhotosUI
extension NSItemProvider{
    func loadimage() async throws ->UIImage?{
        let type: NSItemProviderReading.Type = UIImage.self
        return try await withCheckedThrowingContinuation { continuation in
            loadObject(ofClass: type) { (image, error) in
                if let error{
                    
                    print("loadObject 에러발생")
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: image as? UIImage)
                return
            }
        }
    }
}
extension UIImage{
    static func fetchBy(phResult: PHPickerResult) async throws -> UIImage{
        let item = phResult.itemProvider
        guard let image = try await item.loadimage() else {
            throw ImageManagerError.PHAssetFetchError
        }
        return image
    }
}

