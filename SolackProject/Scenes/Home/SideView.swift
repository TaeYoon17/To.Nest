//
//  SideView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import UIKit
import SnapKit
import SwiftUI
import RxSwift
import Combine
fileprivate class SideVM: ObservableObject{
    @MainActor @Published var isOpen = false
    var closeAction: PassthroughSubject<(),Never> = .init()
}
final class SideVC: UIHostingController<Side>{
    var isOpen:Bool = false{
        didSet{ vm.isOpen = isOpen }
    }
    fileprivate var vm = SideVM()
    var subscription = Set<AnyCancellable>()
    init(){
        super.init(rootView: Side(vm:self.vm))
        isOpen = false
        vm.closeAction.sink { [weak self] _ in
            self?.view.isHidden = true
            self?.isOpen = false
            self?.dismiss(animated: false)
        }.store(in: &subscription)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
}
struct Side:View{
    @ObservedObject fileprivate var vm: SideVM
    @GestureState var expand:CGFloat = 0
    @State var endPo:CGFloat = 0
    @State var nowPo:CGFloat = 0
    @State var isOpen:Bool = false
    var body:some View{
        ZStack(alignment:Alignment(horizontal: .leading, vertical: .center)){
            Color.gray.opacity(isOpen ? 0.85 : 0).ignoresSafeArea()
                .onTapGesture {
                    vm.isOpen = false
                }.zIndex(1)
            if isOpen{
                slider.frame(width: UIScreen.current!.bounds.width * 0.85 + expand)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                    .offset(x:endPo)
                    .offset(x:nowPo)
                    .gesture(DragGesture()
                        .onChanged({ value in
                            if value.translation.width < 0{
                                let width = value.translation.width
                                //                                withAnimation {
                                nowPo = width
                                //                                }
                            }
                        })
                            .updating($expand, body: { val, state, transaction in
                                if val.translation.width > 0{
                                    withAnimation(.easeInOut(duration: 0.66)) {
                                        state = min(12,val.translation.width)
                                    }
                                }
                            }).onEnded({ value in
                                if value.predictedEndLocation.x < 0 || value.translation.width < -200{
                                    withAnimation { endPo = value.translation.width }
                                    vm.isOpen = false
                                    return
                                }
                                //                                withAnimation {
                                nowPo = 0
                                //                                }
                            })
                    )
                    .zIndex(2)
                    .onDisappear(){ // 여기서 ViewController가 입력 처리하도록 바꿔줘야한다!!
                        Task{@MainActor in
                            try await Task.sleep(for: .seconds(0.3))
                            vm.closeAction.send(())
                        }
                    }
            }
        }.statusBar(hidden: true)
            .onReceive(vm.$isOpen, perform: { val in
                print("Side \(val)")
                withAnimation(.easeOut(duration: 0.333)) {
                    isOpen = val
                    if val == false{
                        print("값 입력")
                    }
                }
            })
            .statusBar(hidden:true)
    }
    var slider:some View{
        ZStack(alignment:Alignment(horizontal: .center, vertical: .center)){
            Color.gray1
                .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 24, style: .continuous))
                .ignoresSafeArea()
            VStack{
                Spacer()
                Color.white
                    .frame(height: 44)
                    .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 0, style: .continuous))
                    .ignoresSafeArea()
            }.ignoresSafeArea()
            VStack(spacing:0){
                HStack{
                    Text("워크스페이스").font(FontType.title1.font)
                    Spacer()
                }.frame(height: 44)
                    .padding(.leading,16)
                VStack(spacing:0){
                    Spacer()
                    //                    WorkSpaceEmpty {
                    //                        print("EmptyList")
                    //                    }
                    WorkSpaceList().animation(nil)
                    Spacer()
                    WorkSpaceBottomView()
                        .frame(height: 84)
                        .padding(.bottom,12)
                }
                .background(.white)
                .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 1, topTrailingRadius: 0, style: .continuous))
            }
            
        }
    }
}
struct WorkSpaceEmpty:View {
    let createAction:()->Void
    var body: some View {
        VStack(alignment:.center,spacing:18){
            Text("워크스페이스를\n찾을 수 없어요.").font(FontType.title1.font)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineSpacing(4)
            Text("관리자에게 초대를 요청하거나,\n다른 이메일로 시도하거나\n새로운 워크스페이스를 생성해주세요").font(FontType.body.font)
                .lineLimit(3)
                .multilineTextAlignment(.center)
            Button(action: {
                createAction()
            } , label: {
                Text("워크스페이스 생성")
                    .font(FontType.title2.font)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(.accent).foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal,24)
            })
        }
    }
}
struct WorkSpaceList:View{
    let listItem: [WorkSpaceListItem] = [.init(isSelected: true, imageName: "Metal", name: "iOS Developer Study", date: "22. 03. 23"),
                                         .init(isSelected: false, imageName: "ARKit", name: "영등포 새싹마을 모임", date:"23. 11. 10"),
                                         .init(isSelected: false, imageName: "macOS", name: "모여라 댕댕이", date:"22. 02. 02")]
    @State var managerWorkSpace = false
    @State var defaultWorkSpace = false
    @State var fullScreenGo = false
    @State var isVisible = false
    var body: some View{
        VStack(spacing:0){
            ScrollView {
                LazyVStack(spacing:12){
                    ForEach(listItem.indices,id:\.self){ idx in
                        listItemView(listItem[idx])
                    }
                }
            }
            Spacer()
        }
        .background(.white)
        // 관리자 액션시트
        .confirmationDialog("managerWorkSpace", isPresented: $managerWorkSpace) {
            Button("워크스페이스 편집"){print( "편집 편집")}
            Button("워크스페이스 나가기"){print("나가기")}
            Button("워크스페이스 관리자 변경"){print("나가기")}
            Button("워크스페이스 삭제", role:.destructive){print("나가기")}
            Button("취소", role:.cancel){print("나가기")}
        }
        .confirmationDialog("defaultWorkSpace", isPresented: $defaultWorkSpace) {
            Button("워크스페이스 나가기"){
                fullScreenGo.toggle()
            }
            Button("취소", role:.cancel){print("나가기")}
        }
        .fullScreenCover(isPresented: $fullScreenGo) {
            ZStack {
                if isVisible{
                    VStack(alignment:.center,spacing:16){
                        VStack(alignment: .center,spacing:8){
                            Text("워크스페이스 나가기")
                                .font(FontType.title2.font)
                            Text("회원님은 워크스페이스 관리자입니다. 워크스페이스 관리자를 다른 멤버를 변경한 후 나갈 수 있습니다.")
                                .lineLimit(2)
                                .font(FontType.body.font)
                                .multilineTextAlignment(.center)
                        }.frame(maxWidth: .infinity)
                        Button(action: {
                            isVisible = false
                        }, label: {
                            Text("확인")
                                .font(FontType.title2.font)
                                .frame(height: 44)
                                .frame(maxWidth: .infinity)
                                .background(.accent)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        })
                    }.frame(maxWidth: .infinity)
                        .padding(.vertical,16)
                        .padding(.horizontal,16.5)
                        
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal,24)
                        .onDisappear(){
                            fullScreenGo = false
                        }
                }
            }
            .onAppear{ isVisible = true }
            .background(TransparentBackground())
        }.transaction { transaction in
            transaction.disablesAnimations = true
            transaction.animation = .easeInOut(duration: 0.25)
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
                        defaultWorkSpace.toggle()
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
struct WorkSpaceBottomView:View{
    var body: some View{
        List{
            Button{
                print("wow world")
            }label:{
                Label(
                    title: { Text("워크스페이스 추가").font(FontType.body.font)},
                    icon: { Image(systemName: "plus") }
                )
                
            }.listRowSeparator(.hidden)
            Button{
                print("도움말말말")
            }label:{
                Label(
                    title: { Text("도움말")
                        .font(FontType.body.font)},
                    icon: { Image(systemName: "questionmark.circle") }
                ).listRowSeparator(.hidden)
            }
        }.tint(.secondary)
            .listStyle(.plain)
            .listSectionSeparator(.hidden)
            .scrollDisabled(true)
    }
}
struct WorkSpaceListItem:Identifiable{
    var id = UUID()
    var isSelected:Bool
    var imageName:String
    var name:String
    var date:String // 이거 수정해야함!!
}
struct TransparentBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .gray.withAlphaComponent(0.666)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
