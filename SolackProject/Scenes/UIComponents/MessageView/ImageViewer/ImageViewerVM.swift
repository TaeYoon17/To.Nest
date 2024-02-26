//
//  ImageViewerVM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/26/24.
//

import Foundation
import SwiftUI
import Combine
final class ImageViewerVM: ObservableObject{
    typealias ImageItem = ImgViewerVC.ImageItem
    @MainActor @Published var images:[ImgViewerVC.ImageItem] = []
    @Published var isLoading = true
    let loadingFailedPassthrough = PassthroughSubject<(),Never>()
    private let taskCounter = TaskCounter()
    init(imagePathes:[String]){
        Task{
            do{
                let images = try await taskCounter.run(imagePathes) { imageURL in
                    guard let imageData = await NM.shared.getThumbnail(imageURL),let image = UIImage(data: imageData) else {
                        throw Errors.cachingEmpty
                    }
                    return ImageItem(imageURL: imageURL, image: image)
                }
                await MainActor.run {
                    self.images = images
                    withAnimation {
                        self.isLoading = false
                    }
                }
            }catch{
                self.loadingFailedPassthrough.send(())
            }
        }
        Task{
            try await Task.sleep(for: .seconds(5))
            self.loadingFailedPassthrough.send(())
        }
    }
}
