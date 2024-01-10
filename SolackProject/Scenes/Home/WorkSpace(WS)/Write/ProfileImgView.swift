//
//  ProfileImgView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/10/24.
//

import UIKit
import SwiftUI
import PhotosUI

final class ProfileImgVC: UIHostingController<ProfileImgView>{
    
    init(){
        super.init(rootView: ProfileImgView())
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray1
    }
}

struct ProfileImgView:View{
    //    @State var photosPickerItem:PhotosPickerItem? = nil
    @State var prevImage = false
    @State var pickerPresent: Bool = false
    let defaultImage:Image? = nil
    let size: CGSize = .init(width: 200, height: 200)
//    let width:CGFloat = 44
    var body: some View{
        EditImageView(isPresented:$pickerPresent,cropType: .rectangle(size), content: { state in
            switch state{
            case .empty:
                if let defaultImage{
                    defaultImage.resizable().scaledToFill()
                }else{
                    emptyView
                }
            case .failure(_ ): emptyView
            case .loading(_): ProgressView()
            case .success(let img):
                Image(uiImage: img).resizable(resizingMode: .stretch).scaledToFill()
                    .animToggler()
                    .onAppear(){
                        //                            do{
                        //                                let imgData = try img.jpegData(maxMB: 3)
                        //                                dataAction(imgData)
                        //                            }catch{
                        //                                print(error)
                        //                            }
                    }
            }
        })
        .frame(width: 70,height: 70)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8 ))
        .overlay(alignment: .bottomTrailing){
            Button{
                self.pickerPresent = true
            }label:{
                Image(systemName: "camera.circle.fill")
                    .resizable().scaledToFit()
                    .tint(.accent)
                    .frame(width: 24,height: 24)
                    .background(.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white,lineWidth:2))
            }
            .contentShape(.rect.offset(x:10,y:10))
            .offset(x:10,y:10)
        }
    }
    
    var emptyView: some View{
        RoundedRectangle(cornerRadius: 8).fill(.accent)
            .overlay(alignment:.bottom){
                Image(.workspace).resizable().scaledToFit()
                    .frame(width: 48,height: 60)
            }
    }
}
