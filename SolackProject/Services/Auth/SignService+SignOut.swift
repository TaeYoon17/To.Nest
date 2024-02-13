//
//  SignService+SignOut.swift
//  SolackProject
//
//  Created by 김태윤 on 2/8/24.
//

import Foundation
import RealmSwift
extension SignService{
    func signOut(){
        Task{
            do{
                let isOut = try await NM.shared.signOut()
                if isOut{
                    cleanDefaultsState()
                    await cleanDocument()
                    await cleanDB()
                    print("모두 삭제 완셩")
                }
            }catch{
                print("signout error")
                print(error)
            }
        }
    }
    @BackgroundActor private func cleanDB(){
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
        } catch let error as NSError {
            print("Realm 데이터 삭제 중 오류 발생: \(error.localizedDescription)")
        }
    }
    @BackgroundActor private func cleanDocument() async{
        var imageSnapshot = ImageRCM.shared.snapshot
        var profileSnapshot = UserRCM.shared.snapshot
        await imageSnapshot.allResetCount()
        await profileSnapshot.allResetCount()
        UserRCM.shared.apply(profileSnapshot)
        ImageRCM.shared.apply(imageSnapshot)
        await UserRCM.shared.saveRepository()
        await ImageRCM.shared.saveRepository()
    }
    private func cleanDefaultsState(){
        self.accessToken = ""
        self.refreshToken = ""
        self.myInfo = nil
        self.myProfile = nil
        self.userID = -1
        self.expiration = nil
    }
}
