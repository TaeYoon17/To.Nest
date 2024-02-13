//
//  ChangeManagerComponents.swift
//  SolackProject
//
//  Created by 김태윤 on 2/2/24.
//

import UIKit
import SwiftUI
typealias ChangeManagerListCell = ChangeManager.ChangeManagerListCell
typealias ChangeManagerListItem = ChangeManager.ChangeManagerCellItem
enum ChangeManager{
    static var layout:UICollectionViewCompositionalLayout{
        var listCellConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        listCellConfig.showsSeparators = false
        listCellConfig.backgroundColor = .gray1
        let layout = UICollectionViewCompositionalLayout.list(using: listCellConfig)
        return layout
    }
    struct ChangeManagerListCell: View{
        @ObservedObject var item:ChangeManagerCellItem
        var body: some View{
            HStack(spacing:8){
                item.profileImage.resizable().scaledToFit().frame(width: 44,height: 44).clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment:.leading,spacing:2){
                    Text(item.nickName)
                        .font(FontType.bodyBold.font)
                        .foregroundStyle(.text)
                        .frame(height: 18)
                    Text(verbatim:item.email)
                        .font(FontType.body.font)
                        .foregroundStyle(.secondary)
                        .frame(height:18)
                }
                Spacer()
            }
        }
    }
    final class ChangeManagerCellItem:ObservableObject,Identifiable,Hashable{
        static func == (lhs: ChangeManager.ChangeManagerCellItem, rhs: ChangeManager.ChangeManagerCellItem) -> Bool {
            lhs.id == rhs.id
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        var id:String{"\(userID)"}
        var userID:Int
        @Published var nickName:String
        @Published var profileImage:Image
        @Published var email:String
        init(userID: Int, nickName: String, profileImage: Image, email: String) {
            self.userID = userID
            self.nickName = nickName
            self.profileImage = profileImage
            self.email = email
        }
    }
}
