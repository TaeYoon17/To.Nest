//
//  ProfileService+DB.swift
//  SolackProject
//
//  Created by 김태윤 on 1/31/24.
//

import Foundation
import RealmSwift
import UIKit
extension ProfileService{
    @BackgroundActor func updateInfoDB(info: MyInfo,imageData:Data?) async {
        if let table:UserInfoTable = userRepository.getTableBy(tableID: info.userID){
            let newFilePath = info.profileImage?.webFileToDocFile()
            if table.profileImage != newFilePath{
                if let prevImagePath = table.profileImage{
                    FileManager.removeFromDocument(fileName: prevImagePath)
                }
                if let newPath = info.profileImage,let imageData{
                    do{
                        try imageData.saveToDocument(fileName: newPath.webFileToDocFile())
                    }catch{
                        print("디비 업데이트 오류!! \(error)")
                    }
                }
            }
            await userRepository.update(table: table, nickName: info.nickname, imagePath: newFilePath)
        }
    }
}
