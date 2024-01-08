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
// UIView에선 리액터킷 사용 가능
//final class SideView:BaseView,View,UIGestureRecognizerDelegate{
//    var disposeBag = DisposeBag()
//
//    func bind(reactor: OnboardingViewReactor) {
//    }
//    override func configureLayout() {
//
//    }
//    override func configureConstraints() {
//
//    }
//    override func configureView() {
//        self.backgroundColor = .gray.withAlphaComponent(0.3)
//        let recognize = UIPanGestureRecognizer(target: self, action: #selector(Self.panning))
//        recognize.delegate = self
//        addGestureRecognizer(recognize)
//    }
//    @objc func panning(_ recognizer: UIPanGestureRecognizer){
////        print(recognizer)
//        switch recognizer.state{
//        case .began: print("began")
//        case .changed:
//            print("changed")
//            let loc = recognizer.location(in: self)
//            print("location X:",loc.x)
//            recognizer.setTranslation(loc, in: self)
////            print("")
//        case .ended: print("ended")
//        case .cancelled: print("cancelled")
//        case .possible: print("possible")
//        case .failed: print("failed")
//        @unknown default:
//            fatalError("Don't user")
//        }
//    }
//}
fileprivate class SideVM: ObservableObject{
    @Published var isOpen = false
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
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
struct Side:View{
    @ObservedObject fileprivate var vm: SideVM
    @GestureState var po:CGFloat = 0
    @GestureState var expand:CGFloat = 0
    @State var isOpen:Bool = false
    var body:some View{
        ZStack(alignment:Alignment(horizontal: .leading, vertical: .center)){
            Color.gray.opacity(isOpen ? 0.85 : 0).ignoresSafeArea()
                .onTapGesture {
                    vm.isOpen = false
                }.zIndex(1)
            if isOpen{
                slider.frame(width: 280 + expand)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                    .offset(x:po)
                    .gesture(DragGesture().updating($po, body: { val, state, transaction in
                        if val.translation.width < 0{
                            withAnimation {
                                state = val.translation.width
                            }
                        }
                    }).updating($expand, body: { val, state, transaction in
                        if val.translation.width > 0{
                            withAnimation {
                                state = min(30,val.translation.width)
                            }
                        }
                    }))
                    .zIndex(2)
                    .onDisappear(){ // 여기서 ViewController가 입력 처리하도록 바꿔줘야한다!!
                        
                        Task{@MainActor in
                            try await Task.sleep(for: .seconds(0.3))
//                            vm.isOpen = false
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
    }
    var slider:some View{
        ZStack(alignment:Alignment(horizontal: .leading, vertical: .top)){
            Color.white
                .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 24, topTrailingRadius: 24, style: .continuous))
                .ignoresSafeArea()
            VStack{
                Text("Slider")
                Spacer()
            }.padding()
        }    }
}
