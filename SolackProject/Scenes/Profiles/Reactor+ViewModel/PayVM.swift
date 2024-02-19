//
//  PayVM.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import Foundation
import Combine
import RxSwift
final class PayVM:ObservableObject{
    weak var provider: ServiceProviderProtocol!
    @MainActor @Published var payAmountList: [PayAmountResponse] = []
    private var disposeBag = DisposeBag()
    enum PayAction{
        case requirePay
        case initAction
    }
    init(provider: ServiceProviderProtocol!) {
        self.provider = provider
        binding()
        action(type: .initAction)
    }
    private func binding(){
        provider.payService.event.bind { [weak self] event in
            guard let self else {return}
            switch event{
            case .lists(let response):
                Task{@MainActor in
                    self.payAmountList = response
                }
            }
        }.disposed(by: disposeBag)
    }
    func action(type:PayAction){
        switch type{
        case .initAction:
            provider.payService.getItemList()
        case .requirePay: print("wow world")
        }
    }
}
