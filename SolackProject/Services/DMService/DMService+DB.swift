//
//  DMService+DB.swift
//  SolackProject
//
//  Created by 김태윤 on 2/7/24.
//

import Foundation
extension DMService{
    @BackgroundActor func appendMyRoom(roomID:Int,wsID:Int,userResponse:UserResponse) async {
        if nil == repository.getTableBy(tableID: roomID){
            await repository.create(item: DMRoomTable(roomID: roomID, wsID: wsID, userID: userResponse.userID, createdAt: Date.nowKorDate))
        }
    }
    @BackgroundActor func updateDBRoomProfileImage(response:inout DMRoomResponse) async{
        guard let table = repository.getTableBy(tableID: response.roomID),
              let userTable = userRepository.getTableBy(tableID: table.userID) else {return}
        let newImageURL = response.user.profileImage
        guard userTable.profileImage != newImageURL?.webFileToDocFile() else {return}
        if let prevImagePath = userTable.profileImage,FileManager.checkExistDocument(fileName: prevImagePath){
            FileManager.removeFromDocument(fileName: prevImagePath)
        }
        if let newImageURL,let imageData = await NM.shared.getThumbnail(newImageURL){
            do{
                try imageData.saveToDocument(fileName: newImageURL.webFileToDocFile())
                print("다운로드 성공!!")
            }catch{
                fatalError("updateDBRoomProfileImage")
            }
        }
        response.user.profileImage = newImageURL?.webFileToDocFile()
        await userRepository.update(table: userTable, nickName: response.user.nickname, imagePath: newImageURL?.webFileToDocFile())
    }
}
