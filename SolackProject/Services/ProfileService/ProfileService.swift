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
    func checkProfile(userID:Int)
    func checkMy()
}
final class ProfileService:ProfileProtocol{
    enum Event{
        case myInfo(MyInfo)
        case updatedImage
        case toast(ProfileToastType)
        case otherUserProfile(UserResponse)
    }
    var event:PublishSubject<Event> = .init()
    @DefaultsState(\.myInfo) var myInfo
    @DefaultsState(\.myProfile) var profile
    @DefaultsState(\.userID) var userID
    @BackgroundActor var userRepository:UserInfoRepository!
    init(){
        Task{@BackgroundActor in
            userRepository = try await UserInfoRepository()
        }
    }
    func updateNickname(name:String){
        Task{
            do{
                guard let myInfo else { throw AuthFailed.authFailed }
                let res:MyUpdateInfo = try await NM.shared.updateMyInfo(nickName: name,phone:myInfo.phone)
                await updateInfo(info: res)
                event.onNext(.myInfo(self.myInfo!))
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
                let res:MyUpdateInfo = try await NM.shared.updateMyInfo(nickName: myInfo.nickname,phone:phone)
                await updateInfo(info: res)
                event.onNext(.myInfo(self.myInfo!))
            }catch{
                print("phone failed \(error)")
                event.onNext(.toast(.phoneNumberEditFailed))
            }
        }
    }
    func updateImage(imageData: Data?) {
        Task{
            do{
                let res: MyUpdateInfo = try await NM.shared.updateMyInfo(profileImage: imageData)
                let imageData:Data? = if let imageURL = res.profileImage,let imageData = await NM.shared.getThumbnail(imageURL){
                    imageData
                }else{
                    nil
                }
                self.profile = imageData
                await updateInfo(info: res,imageData: imageData)
                event.onNext(.myInfo(self.myInfo!))
                event.onNext(.updatedImage)
            }catch{
                print("update image error")
                print(error)
            }
        }
    }
    private func updateInfo(info: MyUpdateInfo,imageData:Data? = nil) async{
        let prevImage = myInfo?.profileImage
        self.myInfo?.updateInfo(info)
        self.userID = info.userID
        if let webImage = info.profileImage, prevImage != webImage{
            let data = await NM.shared.getThumbnail(webImage)
            profile = data
        }
        await updateInfoDB(info: self.myInfo!,imageData: imageData)
    }
    func checkProfile(userID:Int){
        Task{
            do{
                let res = try await NM.shared.checkUser(userID: userID)
                self.event.onNext(.otherUserProfile(res))
            }catch{
                print("checkProfile Error \(error)")
            }
        }
    }
    func checkMy(){
        Task{
            do{
                let res = try await NM.shared.checkMy()
                self.myInfo = res
                self.event.onNext(.myInfo(res))
            }catch{
                print("checkMyProfileError \(error)")
            }
        }
    }
}
