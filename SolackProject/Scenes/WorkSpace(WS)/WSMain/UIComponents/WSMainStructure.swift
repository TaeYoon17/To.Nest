//
//  WSMainStructure.swift
//  SolackProject
//
//  Created by 김태윤 on 2/12/24.
//

import Foundation
import UIKit
//MARK: -- 워크스페이스 리스트 아이템
struct WorkSpaceListItem:Identifiable,Equatable{
    var id:Int
    var isSelected:Bool
    var isMyManaging:Bool = false
    var image:UIImage
    var name:String
    var description:String?
    var date:String // 이거 수정해야함!!
}
