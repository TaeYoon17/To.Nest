//
//  EditImageView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import SwiftUI
import PhotosUI
import Combine
typealias EditImageView = ImageManager.CropImageManager.EditImageView
extension ImageManager.CropImageManager{
    struct EditImageView:View{
        let content : (ImageState)-> any View
        let size = CGSize(width: 360, height: 360)
        @State var imageState: ImageState = .empty
        @Binding var isPresented:Bool
        let cropType: CropType
        @State private var prevImage: UIImage? = nil
        @State private var showCropView = false
        @State private var selectedImage: UIImage? = nil
        @State private var croppedImage: UIImage? = nil
        @State private var imageSelection: PhotosPickerItem?
        
        
        init(isPresented: Binding<Bool>,cropType: CropType = .circle(.init(width: 360, height: 360)),content:@escaping (ImageState)->any View){
        스유도_라벨링_됨:do{
            self._isPresented = isPresented
            self.cropType = cropType
            self.content = content
        }
        }
        var body: some View{
            AnyView(content(imageState)).photosPicker(isPresented: $isPresented, selection: $imageSelection,matching: .images)
                .onChange(of: imageSelection, perform: { newValue in
                    guard let newValue else {return}
                    let progress = newValue.loadTransferable(type: ImageData.self) {result in
                        Task {@MainActor in
                            guard imageSelection == self.imageSelection else {
                                print("Failed to get the selected item.")
                                return
                            }
                            switch result {
                            case .success(let profileImage?):
                                let uiimage = UIImage.fetchBy(data: profileImage.image,size: size)
                                self.selectedImage = uiimage
                            case .success(nil):
                                imageState = .empty
                            case .failure(let error):
                                imageState = .failure(error)
                            }
                        }
                    }
                    imageState = .loading(progress)
                })
                .onChange(of: selectedImage, perform: { newValue in
                    if let newValue{
                        self.showCropView = true
                    }
                })
                .fullScreenCover(isPresented: $showCropView, onDismiss: {
                    selectedImage = nil
                }, content: {
                    CropView(image: selectedImage,cropType:cropType){ croppedImage,status in
                        if !status{
                            self.croppedImage = croppedImage
                        }else{
                            self.imageState = .failure(ImageManagerError.PHAssetFetchError)
                        }
                    }
                    .onDisappear(){
                        if let croppedImage{
                            self.imageState = .success(croppedImage)
                            prevImage = croppedImage
                        }else{
                            if let prevImage{
                                self.imageState = .success(prevImage)
                            }else{
                                self.imageState = .empty
                            }
                        }
                        croppedImage = nil
                    }
                    
                })
                .onTapGesture { isPresented.toggle() }
        }
    }
}

