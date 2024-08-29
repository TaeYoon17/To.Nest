//
//  WorkSpaceListView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
fileprivate struct WorkSpaceListInner<T: View>:View{
    let view:()->T
    @EnvironmentObject var vm: WSMainVM
    @Binding var managerWorkSpace:Bool
    @Binding var defaultWorkSpace:Bool
    @State var fullScreenGo = false
    @State var isVisible = false
    //    @State var managerEdit = false
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
                vm.editWorkSpaceManagerTapped.send(())
            }, delete: {
                goAnim { managerDelete = true }
            }, change: {
                //                goAnim { managerChangeError = true }
                vm.changeWorkSpaceManagerTapped.send(())
            }, exit: { goAnim { managerExit = true }
            }, cancel: {})
            .userDialog($defaultWorkSpace, exit: {
                goAnim { userExit = true }
            }, cancel: {})
        //MARK: -- SolackAlert 내부에 애니메이션 처리가 되어있음!!
            .solackAlert($managerDelete, title: "채널 삭제", description: "정말 이 채널을 삭제하시겠습니까? 삭제 시 멤버/채팅 등 채널 내의 모든 정보가 삭제되며 복구할 수 없습니다.", cancelTitle: "취소", cancel: {
                
            },confirmTitle: "삭제",confirm: {
                print("manager delete 삭제...")
                vm.deleteWorkSpace()
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
                vm.exitWorkSpace()
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
    @EnvironmentObject var vm: WSMainVM
    @State fileprivate var isUserSelected:Bool = false
    @State fileprivate var isManagerSelected:Bool = false
    @State private var list:[WorkSpaceListItem] = []
    var body:some View{
        WorkSpaceListInner(manager: $isManagerSelected, user: $isUserSelected) {
            VStack(spacing:0){
                if list.isEmpty{
                    WorkSpaceEmpty { vm.createWorkSpaceTapped.send(()) }
                }else{
                    ScrollView {
                        LazyVStack(spacing:12){
                            ForEach(vm.list.indices,id:\.self){ idx in
                                Button{
                                    // 고유 workspaceitemID를 바꾼다.
                                    vm.updateMainWS(idx: idx)
                                }label:{
                                    listItemView(vm.list[idx])
                                }.transaction { transaction in
                                    transaction.disablesAnimations = false
                                    transaction.animation = nil
                                }
                            }
                        }
                        
                    }.opacity(list.isEmpty ? 0 : 1).scrollIndicators(.never)
                    Spacer()
                }
            }
            .onChange(of: vm.list) { newValue in
                withAnimation { list = newValue }
            }
        }
        .environmentObject(vm)
    }
    func listItemView(_ item:WorkSpaceListItem) -> some View{
        HStack(alignment:.center, spacing:8){
            let size = CGSize(width: 44, height: 44)
            Image(uiImage: item.image).resizable().frame(size).clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading,spacing: 4){
                Text(item.name).font(FontType.bodyBold.font)
                Text(item.date).font(FontType.body.font).foregroundStyle(.secondary)
            }
            Spacer()
            if item.isSelected{
                Button{
                    if item.isMyManaging{
                        isManagerSelected.toggle()
                    }else{
                        isUserSelected.toggle()
                    }
                }label: {
                    Image(systemName: "ellipsis").fontWeight(.medium)
                        .padding(.leading,20)
                        .padding(.vertical,4)
                        .padding(.horizontal,4)
                }.tint(.text)
                    .zIndex(2)
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
