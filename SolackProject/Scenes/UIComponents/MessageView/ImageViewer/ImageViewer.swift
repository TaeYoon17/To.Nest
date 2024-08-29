//
//  ImageViewer.swift
//  SolackProject
//
//  Created by 김태윤 on 2/21/24.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftUI
import Combine
import CoreTransferable
import UniformTypeIdentifiers
final class ImgViewerVC: UIHostingController<ImgViewer>{
    init(imagePathes: [String]){
        let vm = ImageViewerVM(imagePathes: imagePathes)
        super.init(rootView: ImgViewer(vm: vm))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    deinit{ UINavigationBar.appearance().barStyle = .default }
    struct ImageItem:Identifiable,Hashable{
        var id:String{imageURL}
        let imageURL:String
        let image: UIImage
        init(imageURL: String, image: UIImage) {
            self.imageURL = imageURL
            self.image = image
        }
    }
}
struct ImgViewer: View{
    @StateObject var vm: ImageViewerVM
    @State var showNavigation = true
    @Environment(\.dismiss) var dismiss
    @State var pageIndex = 0
    var body: some View{
        Group{
            if vm.isLoading{
                Color.black.overlay {
                    ProgressView().tint(.accent)
                }
            }else{
                TabView(selection: $pageIndex,content: {
                    ForEach(vm.images.indices,id:\.self) { idx in
                        ImageCellView(image: vm.images[idx].image).ignoresSafeArea(.all)
                            .background(.black)
                            .tag(idx)
                    }
                }).tabViewStyle(.page(indexDisplayMode: .never)).ignoresSafeArea(.all)
            }
        }.overlay(alignment: .top) {
            if showNavigation{ navigationBar }
        }
        .statusBar(hidden: !showNavigation)
        .onTapGesture { withAnimation { showNavigation.toggle() } }
        .background(.black)
    }
}
extension ImgViewer{
    var navigationBar: some View{
        HStack(content: {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17,weight: .bold))
                    .imageScale(.large)
            }).padding(.leading,16.5)
            Spacer()
            ShareLink(items: vm.images.map{Image(uiImage: $0.image)}) { image in
                SharePreview("\(vm.images.count)개의 이미지", image: image)
            }
            .labelStyle(.iconOnly)
            .font(.system(size: 17,weight: .bold))
            .imageScale(.large).padding(.trailing,16.5)
        })
        .padding(.bottom,8)
        .overlay(alignment: .center, content: {
            if vm.images.count > 0{
                Text("\(pageIndex + 1) / \(vm.images.count)")
                    .font(.system(size: 17,weight: .bold)).foregroundStyle(.white)
            }
        })
        .background(.black.opacity(0.66)).tint(.white)
    }
}
