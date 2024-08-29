//
//  PaymentView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/20/24.
//

import Foundation
import SwiftUI
import UIKit
import WebKit
import iamport_ios


struct PaymentView: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: PayVM
    
    func makeUIViewController(context: Context) -> UIViewController {
        let view = PaymentViewController()
        view.viewModel = viewModel
        return view
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

class PaymentViewController: UIViewController, WKNavigationDelegate {
    var viewModel: PayVM? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PaymentView viewDidLoad")
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PaymentView viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PaymentView viewDidAppear")
        requestPayment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("PaymentView viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("PaymentView viewDidDisappear")
    }
    
    
    // 아임포트 SDK 결제 요청
    func requestPayment() {
        guard let viewModel = viewModel else {
            print("viewModel 이 존재하지 않습니다.")
            return
        }
        
        Iamport.shared.useNavigationButton(enable: true)
        if let payment = viewModel.makePayment(){
            Iamport.shared.payment(viewController: self, userCode: IamportPay.userCode, payment: payment) {[weak self] response in
                guard let self,let response else {return}
                viewModel.action(type: .requireValidation(imp: response.imp_uid ?? "", merchant: response.merchant_uid ?? ""))
            }
        }
    }
    
}
