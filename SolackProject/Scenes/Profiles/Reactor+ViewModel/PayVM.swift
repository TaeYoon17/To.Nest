//
//  PayVM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import Foundation
import Combine
import RxSwift
import SwiftUI
import iamport_ios

final class PayVM:ObservableObject{
    weak var provider: ServiceProviderProtocol!
    @MainActor @Published var payAmountList: [PayAmountResponse] = []
    @MainActor @Published var payAmount: PayAmountResponse? = nil
    @MainActor @Published var isPayment: Bool = false
    @MainActor @Published var nowPossessionCoin: Int = 0
    @MainActor @Published var toastType: PayToastType? = nil
    @DefaultsState(\.myInfo) var myInfo
    private var disposeBag = DisposeBag()
    enum PayAction{
        case requirePay(payAmount:PayAmountResponse)
        case requireValidation(imp:String,merchant:String)
        case closePay
        case initAction
    }
    init(provider: ServiceProviderProtocol!) {
        self.provider = provider
        binding()
        self.action(type: .initAction)
    }
    private func binding(){
        provider.payService.event.bind { [weak self] event in
            guard let self else {return}
            switch event{
            case .lists(let response):
                Task{@MainActor in
                    self.payAmountList = response
                }
            case .bill(let bill):
                Task{@MainActor in
                    self.nowPossessionCoin = self.myInfo!.sesacCoin
                    self.toastType = bill.success ? .success : nil
                    try await Task.sleep(for: .seconds(2))
                    self.toastType = nil
                }
            case .error(let payFailed):
                Task{@MainActor in
                    self.toastType = .validFailure
                    try await Task.sleep(for: .seconds(2))
                    self.toastType = nil
                }
            }
        }.disposed(by: disposeBag)
        provider.profileService.event.bind { [weak self] event in
            guard let self else {return}
            switch event{
            case .myInfo(let myInfo):
                Task{@MainActor in
                    self.nowPossessionCoin = myInfo.sesacCoin
                }
            default: break
            }
        }.disposed(by: disposeBag)
    }
    func action(type:PayAction){
        switch type{
        case .initAction:
            Task{
                provider.profileService.checkMy()
                provider.payService.getItemList()
            }
        case .requirePay(let payAmount):
            Task{@MainActor in
                self.isPayment = true
                self.payAmount = payAmount
            }
        case .closePay:
            Task{@MainActor in
                self.isPayment = false
                self.payAmount = nil
            }
        case .requireValidation(imp: let imp, merchant: let merchant):
            provider.payService.validation(imp: imp, merchant: merchant)
        }
    }
}
extension PayVM{
    private func merchant_uid() -> String{
        "ios_\(API.key)_\(Int(Date().timeIntervalSince1970))"
    }
    @MainActor func makePayment() -> IamportPayment?{
        guard let myInfo,let payAmount else {return nil}
        let payment = IamportPayment(
                    pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                    merchant_uid: self.merchant_uid(),
                    amount: payAmount.amount
                    )
        payment.pay_method = PayMethod.card.rawValue
        payment.name = payAmount.item
        payment.buyer_name = myInfo.nickname
        payment.app_scheme = "payment"
        return payment
    }
}
