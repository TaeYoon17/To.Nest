//
//  CropView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import Foundation
import SwiftUI
typealias CropView = ImageManager.CropImageManager.CropView
extension ImageManager.CropImageManager{
    struct CropView: View{
        //    fileprivate var crop:Crop = .circle
        var image:UIImage?
        let cropType: CropType
        var onCrop: (UIImage?,Bool) -> ()
        
        @Environment(\.dismiss) var dismiss
        @State private var scale: CGFloat = 1
        @State private var lastScale: CGFloat = 0
        @State private var offset: CGSize = .zero
        @State private var lastStoredOffset: CGSize = .zero
        @GestureState private var isInteracting: Bool = false  // 인터렉션 중인지 알려줌
        @State private var maskHidden = false
        
        var body: some View{
            NavigationStack{
                imageView()
                    .navigationTitle("Crop View")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarBackground(Color.black, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                    .background(.black)
                    .toolbar{
                        ToolbarItem(placement: .topBarTrailing) {
                            Button{
                                @MainActor func rendering<T:View>(_ shape:T,size:CGSize){
                                    let renderer = ImageRenderer(content: shape)
                                    renderer.proposedSize = .init(size)
                                    if let image = renderer.uiImage{
                                        onCrop(image,false)
                                    }else{
                                        onCrop(image,true)
                                    }
                                }
                                switch cropType{
                                case .circle(let cGSize):
                                    rendering(imageView().clipShape(Circle()),size: cGSize)
                                case .rectangle(let cGSize):
                                    rendering(imageView().clipShape(Rectangle()),size: cGSize)
                                }
                                dismiss()
                            }label: {
                                Text("Done").font(.headline)
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button{
                                onCrop(nil,false)
                                dismiss()
                            }label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    .onAppear(){
                        Task{  @MainActor in
                            try await Task.sleep(for: .seconds(0.33))
                            withAnimation { maskHidden = true }
                        }
                    }
            }
        }
        
    }
}
extension ImageManager.CropImageManager.CropView{
    @ViewBuilder func imageView()->some View{
        let cropSize = switch cropType{
        case .circle(let size): size
        case .rectangle(let size): size
        }
        ZStack(alignment: .center){
            GeometryReader{ proxy in
                let size = proxy.size
                if let image{
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(content: {
                            GeometryReader(content: { proxy in
                                let rect = proxy.frame(in: .named("CROPVIEW"))
                                Color.clear.onChange(of: isInteracting) { newValue in
                                    /// true -> 드래그
                                    /// false -> 드래그 멈춤
                                    /// 이거 사용해서 최소 x,y / 최대 x,y를 알 수 있다.
                                    withAnimation(.easeInOut(duration: 0.2)){
                                        if rect.minX > 0{
                                            offset.width = (offset.width - rect.minX)
                                        }
                                        if rect.minY > 0{
                                            offset.height = offset.height - rect.minY
                                        }
                                        if rect.maxX < size.width{
                                            offset.width = rect.minX - offset.width
                                        }
                                        if rect.maxY < size.height{
                                            offset.height = rect.minY - offset.height
                                        }
                                    }
                                    
                                    if !newValue{
                                        lastStoredOffset = offset
                                    }
                                }
                            })
                        })
                        .frame(size)
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .coordinateSpace(name:"CROPVIEW")
            .frame(cropSize)
            if maskHidden{
                ZStack(alignment: .center){
                    Rectangle()
                        .animation(.easeInOut(duration: 0.2), value: isInteracting)
                        .foregroundStyle(Color.black.opacity(isInteracting ? 0.5 : 1))
                    
                    switch cropType{
                    case .circle:
                        Circle().frame(cropSize)
                            .blendMode(.destinationOut)
                    case .rectangle:
                        Rectangle().frame(cropSize)
                            .blendMode(.destinationOut)
                    }
                }
                .compositingGroup()
            }
        }.gesture(
            DragGesture().updating($isInteracting, body: { val, state, transact in
                state = true
            }).onChanged({ value in
                let translation = value.translation
                offset = CGSize(width: translation.width + lastStoredOffset.width, height: translation.height + lastStoredOffset.height)
            })
        )
        //MARK: -- Magnify Gesture
        .gesture(MagnificationGesture()
            .updating($isInteracting, body: { val, state, transct in
                state = true
            }).onChanged({ value in
                
                let updatedScale = value.magnitude + lastScale
                scale = (updatedScale < 1 ? 1 : updatedScale)
            }).onEnded({ value in
                withAnimation {
                    if scale < 1{
                        scale = 1
                        lastScale = 0
                    }else{
                        lastScale = scale - 1
                    }
                }
            }))
        .ignoresSafeArea()
    }
}
    
