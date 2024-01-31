//
//  ProfileService.swift
//  SolackProject
//
//  Created by 김태윤 on 1/31/24.
//

import Foundation
import RxSwift
typealias PfService = ProfileService
protocol ProfileProtocol{
    var event:PublishSubject<PfService.Event> {get}
    func updateNickname(name:String)
    func updatePhone(phone:String)
    func updateImage(imageData:Data?)
}
final class ProfileService:ProfileProtocol{
    enum Event{
        case myInfo(MyInfo)
        case updatedImage
        case toast(MyProfileToastType)
    }
    var event:PublishSubject<Event> = .init()
    @DefaultsState(\.myInfo) var myInfo
    @DefaultsState(\.myProfile) var profile
    @DefaultsState(\.userID) var userID
    func updateNickname(name:String){
        Task{
            do{
                guard let myInfo else { throw AuthFailed.authFailed }
                let res:MyInfo = try await NM.shared.updateMyInfo(nickName: name,phone:myInfo.phone)
                
                await updateInfo(info: res)
                event.onNext(.myInfo(res))
            }catch{
                print("nickname failed \(error)")
                event.onNext(.toast(.nicknameEditFailed))
            }
        }
    }
    func updatePhone(phone:String){
        Task{
            do{
                guard let myInfo else { throw AuthFailed.authFailed }
                let res:MyInfo = try await NM.shared.updateMyInfo(nickName: myInfo.nickname,phone:phone)
                await updateInfo(info: res)
                event.onNext(.myInfo(res))
            }catch{
                print("phone failed \(error)")
                event.onNext(.toast(.phoneNumberEditFailed))
            }
        }
    }
    func updateImage(imageData: Data?) {
        Task{
            do{
                let res: MyInfo = try await NM.shared.updateMyInfo(profileImage: imageData)
                await updateInfo(info: res)
                if let imageURL = res.profileImage,let imageData = await NM.shared.getThumbnail(imageURL){
                    self.profile = imageData
                }else{
                    self.profile = nil
                }
                event.onNext(.myInfo(res))
                event.onNext(.updatedImage)
            }catch{
                print("update image error")
                print(error)
            }
        }
    }
    private func updateInfo(info: MyInfo) async{
        let prevImage = myInfo?.profileImage
        self.myInfo = info
        self.userID = info.userID
        if let webImage = info.profileImage, prevImage != webImage{
            let data = await NM.shared.getThumbnail(webImage)
            profile = data
        }
    }
}
