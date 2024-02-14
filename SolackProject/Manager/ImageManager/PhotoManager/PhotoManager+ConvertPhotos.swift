//
//  ImageService+ConvertPhotos.swift
//  SolackProject
//
//  Created by 김태윤 on 1/26/24.
//

import Foundation
import Photos
import PhotosUI
import Combine
extension PhotoManager{
    func getDownloadTarget(results: [PHPickerResult])->[PHPickerResult]{
        return results.filter{ $0.itemProvider.canLoadObject(ofClass: UIImage.self)
        }.filter{!FileManager.checkExistDocument(fileName: $0.assetIdentifier!.getLocalPathName(type: .photo), type: .jpg)}
    }
    func saveToDocumentBy(result:PHPickerResult)async throws{
        let item = result.itemProvider
        let image = try await item.loadimage()
        let fileName = result.assetIdentifier!.getLocalPathName(type: .photo)
        image?.saveToDocument(fileName: fileName)
    }
}
extension String{
    enum SourceType{
        case photo
        case search
    }
    func getLocalPathName(type: SourceType)->String{
        switch type{
        case .photo:
            return ""
        case .search:
            var list = self.split(separator: "/")
            let last = list.popLast()!.split(separator: ".")[0]
            if let lastprev = list.popLast(){
                return "\(lastprev)_\(last)"
            }else{
                return "\(last)"
            }
        }
    }
}
extension UIImage{
    private func bytesToMegabytes(bytes: Int) -> CGFloat {
        let megabyte = Double(bytes) / 1024 / 1024
        return megabyte
    }
    func saveToDocument(fileName: String,maxMegaBytes:CGFloat = 3){
        //1. 도큐먼트 경로 찾기
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        //2. 저장할 파일의 세부 경로 설정
        let fileURL = documentDir.appendingPathComponent("\(fileName)")
        //3. 이미지 변환 -> 세부 경로 파일을 열어서 저장
        guard let data = self.jpegData(compressionQuality: 1) else {return}
        let mbBytes = bytesToMegabytes(bytes: data.count)
        let maxQuality = min(maxMegaBytes / mbBytes,1) // 모든 이미지 데이터를 3mb 이하로 맞추기
        guard let data = self.jpegData(compressionQuality: maxQuality) else { return }
        //4. 이미지 저장
        do{
            try data.write(to: fileURL)
        }catch let err{
            print("file save error",err)
        }
    }
}
