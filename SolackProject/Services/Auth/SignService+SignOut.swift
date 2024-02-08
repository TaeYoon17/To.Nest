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
        NM.shared.signOut()
        cleanDefaultsState()
        Task{
            await cleanDocument()
            await cleanDB()
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
