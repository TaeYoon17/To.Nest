//
//  WSMainItemMaker.swift
//  SolackProject
//
//  Created by 김태윤 on 2/12/24.
//

import Foundation
import UIKit
extension WSMainVM{
    func makeWSItem(_ res:WSResponse,coverCache:Bool = false) async throws -> WorkSpaceListItem{
        let myImage:UIImage
        do{
            myImage = try await UIImage.fetchWebCache(name: res.thumbnail,type:.small)
        }catch{
            let image = if let data = await NM.shared.getThumbnail(res.thumbnail){
                UIImage.fetchBy(data: data,type:.small)
            }else{examineImage.randomElement()!}
            try await image.appendWebCache(name: res.thumbnail,isCover: coverCache)
            myImage = try image.downSample(type:.small)
        }
        return await WorkSpaceListItem(id:res.workspaceID,
                                       isSelected: res.workspaceID == mainWS.id,
                                       isMyManaging: res.ownerID == userID,
                                       image: myImage,
                                       name: res.name,
                                       description: res.description,
                                       date: res.createdAt.convertToDate().wsDateConverter())
    }
}
