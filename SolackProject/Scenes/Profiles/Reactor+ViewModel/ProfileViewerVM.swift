//
//  ProfileViewerVM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/13/24.
//

import Foundation
import RxSwift
import SwiftUI
final class ProfileViewerVM:ObservableObject{
    weak var provider: ServiceProviderProtocol!
    var disposeBag = DisposeBag()
    var goBackNavigation = PublishSubject<()>()
    @Published var image:Image = Image(.noPhotoA)
    @Published var nickName:String = ""
    @Published var email:String = ""
    init(provider:ServiceProviderProtocol,userID:Int){
        self.provider = provider
        provider.profileService.checkProfile(userID: userID)
        binding()
        
    }
    func binding(){
        provider.profileService.event.bind { [weak self] event in
            guard let self else {return}
            switch event{
            case .otherUserProfile(let userResponse):
                Task{[weak self] in
                    guard let self else {return}
                    let image = if let imageURL = userResponse.profileImage,let imageData = await NM.shared.getThumbnail(imageURL){
                        Image(uiImage: UIImage.fetchBy(data: imageData, type: .large))
                    }else{
                        Image(.noPhotoA)
                    }
                    Task{@MainActor in
                        self.image = image
                        self.nickName = userResponse.nickname
                        self.email = userResponse.email
                    }
                }
            default:break
            }
        }.disposed(by: disposeBag)
    }
}
