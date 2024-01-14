//
//  SolackAlert.swift
//  SolackProject
//
//  Created by 김태윤 on 1/9/24.
//

import SwiftUI
import UIKit
import Combine
final class SolackAlertVC: BaseVC{
    let alertTitle:String
    let alertDescription:String
    let cancelTitle:String
    let cancel:()->()
    let infos:[String]
    let confirmTitle:String?
    let confirm:(()->())?
    fileprivate var buttonVC: SolackAlertButtonVC!
    init(title:String,description:String,infos:[String] = [],cancelTitle:String,cancel:@escaping ()->(),confirmTitle:String? = nil,confirm:(()->())? = nil){
        self.alertTitle = title
        self.alertDescription = description
        self.cancel = cancel
        self.cancelTitle = cancelTitle
        self.infos = infos
        self.confirmTitle = confirmTitle
        self.confirm = confirm
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 0.33) {[weak self] in
            self?.view.backgroundColor = .gray.withAlphaComponent(0.33)
        }
        buttonVC = .init(title: "코인이 없어요", description: "어쩔 티비", cancelTitle: "오키", cancel: {[weak self] in
            self?.cancel()
            UIView.animate(withDuration: 0.33) {
                self?.buttonVC.view.backgroundColor = .clear
            }completion: { _ in
                self?.dismiss(animated: false)
            }
        })
        addChild(buttonVC)
        view.addSubview(buttonVC.view)
        buttonVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
//    deinit{
//        print("SolackAlertVC Deinit!!")
//    }
}
//MARK: -- SwiftUIView Wrapper
fileprivate final class SolackAlertButtonVC: UIHostingController<SolackAlertView>{
    init(title:String,description:String,infos:[String] = [],cancelTitle:String,cancel:@escaping ()->(),confirmTitle:String? = nil,confirm:(()->())? = nil){
        let solackAlert = SolackAlertView(title: title, description: description, infos: infos, cancelTitle: cancelTitle, cancel: cancel, confirmTitle: confirmTitle,confirm: confirm)
        super.init(rootView: solackAlert)
        self.view.backgroundColor = .clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
struct SolackAlertView:View{
    let title:String
    let description:String
    let infos:[String]
    let cancelTitle:String
    let cancel:()->()
    let confirmTitle:String?
    var confirm:(()->())?
    @State var isVisible = true
    var body:some View{
        VStack(alignment:.center,spacing:16){
            VStack(alignment: .center,spacing:8){
                Text(title)
                    .font(FontType.title2.font)
                Text(description)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(FontType.body.font)
                    .multilineTextAlignment(.center)
                if !infos.isEmpty{
                    Text(infos.reduce(into: "") { $0 = $0 + "• \($1)\n" })
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.frame(maxWidth: .infinity)
            if let confirm{
                SolackDoubleLabel(cancelTitle: cancelTitle, cancelAction: {
                    cancel()
                    withAnimation {
                        isVisible = false
                    }
                }, cinfirmAction: {
                    confirm()
                }, confirmTitle: confirmTitle)
            }else{
                SolackSingleLabel(cancelAction: {
                    cancel()
                    withAnimation {
                        isVisible = false
                    }
                }, cancelTitle: cancelTitle)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .frame(maxWidth: .infinity)
        .padding(.vertical,16)
        .padding(.horizontal,16.5)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal,24)
        .background(TransparentBackground(isVisible: $isVisible))
        .onAppear(){
            withAnimation { isVisible = true }
        }
    }
}



