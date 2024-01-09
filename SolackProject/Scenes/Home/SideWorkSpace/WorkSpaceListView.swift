//
//  WorkSpaceListView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
fileprivate struct WorkSpaceListInner<T: View>:View{
    let view:()->T
    @Binding var managerWorkSpace:Bool
    @Binding var defaultWorkSpace:Bool
    @State var fullScreenGo = false
    @State var isVisible = false
    @State var managerEdit = false
    @State var managerExit = false
    @State var managerChangeError = false
    @State var managerDelete = false
    @State var userExit = false
    init(manager:Binding<Bool>,user:Binding<Bool>,view:@escaping ()->T){
        self._managerWorkSpace = manager
        self._defaultWorkSpace = user
        self.view = view
    }
    var body: some View{
        view()
            .background(.white)
            .managerDialog($managerWorkSpace, edit: {// 관리자 액션시트
                managerEdit = true
            }, delete: {
                goAnim { managerDelete = true }
            }, change: {
                goAnim { managerChangeError = true }
            }, exit: { goAnim { managerExit = true }
            }, cancel: {
                print("나가기")
            })
            .userDialog($defaultWorkSpace, exit: {
                goAnim { userExit = true }
            }, cancel: {
                print("나가기")
            })
//MARK: -- SolackAlert내부에 애니메이션 처리가 되어있음!!
            .solackAlert($managerDelete, title: "채널 삭제", description: "정말 이 채널을 삭제하시겠습니까? 삭제 시 멤버/채팅 등 채널 내의 모든 정보가 삭제되며 복구할 수 없습니다.", cancelTitle: "취소", cancel: {
                
            },confirmTitle: "삭제",confirm: {
                print("manager delete 삭제...")
            })
            .solackAlert($managerChangeError, title: "워크스페이스 관리자 변경 불가", description: "워크스페이스 멤버가 없어 관리자 변경을 할 수 없습니다.\n새로운 멤버를 워크스페이스에 초대해보세요.", cancelTitle: "확인", cancel: {
                print("wow world!!")
            })
            .solackAlert($managerExit, title: "워크스페이스 나가기", description: "회원님은 워크스페이스 관리자입니다. 워크스페이스 관리자를 다른 멤버를 변경한 후 나갈 수 있습니다.", cancelTitle: "확인", cancel: {
                
            })
            .solackAlert($userExit, title: "워크스페이스 나가기", description: "정말 워크스페이스를 나가시겠습니까?",
                         cancelTitle: "취소",
                         cancel: {
                
                        },
                         confirmTitle:"나가기",
                         confirm: {
                print("user exit ok")
            })
            
            
    }
    private func goAnim(action:()->()){
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}

struct WorkSpaceList:View{
    @State fileprivate var isUserSelected:Bool = false
    @State fileprivate var isManagerSelected:Bool = false
    let listItem: [WorkSpaceListItem] = [.init(isSelected: true,isMyManaging: true, imageName: "Metal", name: "iOS Developer Study", date: "22. 03. 23"),
                                         .init(isSelected: false, imageName: "ARKit", name: "영등포 새싹마을 모임", date:"23. 11. 10"),
                                         .init(isSelected: false, imageName: "macOS", name: "모여라 댕댕이", date:"22. 02. 02")]
    var body:some View{
        WorkSpaceListInner(manager: $isManagerSelected, user: $isUserSelected) {
            VStack(spacing:0){
                ScrollView {
                    LazyVStack(spacing:12){
                        ForEach(listItem.indices,id:\.self){ idx in
                            listItemView(listItem[idx]).transaction { transaction in
                                transaction.disablesAnimations = false
                                transaction.animation = nil
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
    func listItemView(_ item:WorkSpaceListItem) -> some View{
        Button{
            print("리스트 아이템")
        }label:{
            HStack(alignment:.center, spacing:8){
                Image(item.imageName).resizable().frame(width: 44,height:44).clipShape(RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading){
                    Text(item.name).font(FontType.bodyBold.font)
                    Text(item.date).font(FontType.body.font).foregroundStyle(.secondary)
                }
                Spacer()
                if item.isSelected{
                    Button{
                        if item.isMyManaging{
                            //                        defaultWorkSpace.toggle()
                            isManagerSelected.toggle()
                        }else{
                            isUserSelected.toggle()
                        }
                    }label: {
                        Image(systemName: "ellipsis").fontWeight(.medium)
                    }.tint(.text)
                        .zIndex(2)
                }
            }
        }
        .padding(.all,8)
        .background(item.isSelected ? .gray2 : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal,8)
        .zIndex(1)
        .listRowSeparator(.hidden)
        .tint(.text)
    }
}
