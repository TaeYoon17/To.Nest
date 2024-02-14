//
//  PhotoManager.swift
//  SolackProject
//
//  Created by 김태윤 on 1/26/24.
//

import Foundation
import Photos
import PhotosUI
import Combine
import UIKit
import RxSwift
typealias PhotoManager = ImageManager.PhotoManager
typealias PM = PhotoManager
extension ImageManager{
    final class PhotoManager{
        static let shared = PhotoManager()
        private weak var viewController: UIViewController?
        private let cachingManager = PHCachingImageManager()
        var subscription = Set<AnyCancellable>()
        var disposeBag = DisposeBag()
        static let limitedNumber = 5
        var counter = TaskCounter()
        let fileResults: PublishSubject<(UIViewController,news:[FileData],remains:[String])> = .init()
        var prevIdentifiers:[String]? = nil
        func presentPicker(vc: UIViewController,multipleSelection: Bool = false,prevIdentifiers:[String]? = nil) {
            self.viewController = vc
            let filter = PHPickerFilter.images
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = filter
            configuration.preferredAssetRepresentationMode = .automatic
            configuration.selection = .ordered
            configuration.selectionLimit = multipleSelection ? Self.limitedNumber : 1
            if let prevIdentifiers{
                configuration.preselectedAssetIdentifiers = prevIdentifiers
                self.prevIdentifiers = prevIdentifiers
            }
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            viewController?.present(picker, animated: true)
        }
        func presentPicker(vc: UIViewController,maxSelection:Int = 5) {
            self.viewController = vc
            let filter = PHPickerFilter.images
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            configuration.filter = filter
            configuration.preferredAssetRepresentationMode = .automatic
            configuration.selection = .default
            configuration.selectionLimit = maxSelection
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            viewController?.present(picker, animated: true)
        }
    }
    func isValidAuthorization() async -> Bool{
        // Observe photo library changes
        await withCheckedContinuation({ continuation in
            switch authorizationStatus{
            case .notDetermined:
                let requiredAccessLevel: PHAccessLevel = .readWrite
                PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { authorizationStatus in
                    switch authorizationStatus {
                    case .limited, .authorized: continuation.resume(returning: true)
                    default: continuation.resume(returning: false)
                    }
                }
            default: continuation.resume(returning: true)
            }
        })
    }
    
    
    func presentToLibrary(vc: UIViewController){
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: vc)
    }
    func deinitToLibrary(vc: PHPhotoLibraryChangeObserver){
        PHPhotoLibrary.shared().unregisterChangeObserver(vc)
    }
    var authorizationStatus:PHAuthorizationStatus{
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
}
extension PM:PHPickerViewControllerDelegate{
    // 델리게이트 구현 사항
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        viewController?.dismiss(animated: true)
        Task{
            do{
                try await downloadToDocument(results: results)
                self.prevIdentifiers = nil
                self.viewController = nil
            }catch{
                print("PHPicker finish error")
                print(error)
            }
        }
    }
    func downloadToDocument(results:[PHPickerResult])async throws{
        guard let viewController else {return}
        let prevIdentifiers = prevIdentifiers
        let itemReusults:[(UIImage?,String?)] = try await counter.run(results) { result in
            let item = result.itemProvider
            guard let identifier =  result.assetIdentifier else {return (nil,nil)}
            if let prevIdentifiers,prevIdentifiers.contains(identifier){
                return (nil,identifier)
            }else{
                let image = try await item.loadimage()
                return (image,result.assetIdentifier)
            }
        }
        var fileDatas:[FileData] = []
        var remains:[String] = []
        for result in itemReusults{
            guard let identifier = result.1 else { throw ImageManagerError.PHAssetFetchError }
            guard let image = result.0 else {
                remains.append(identifier)
                continue
            }
            let data = try image.imageData(maxMB: 10)
            let fileData = FileData(file: data, type: .jpg, name: identifier)
            fileDatas.append(fileData)
        }
        self.fileResults.onNext((self.viewController!,fileDatas,remains))
    }
    
}
