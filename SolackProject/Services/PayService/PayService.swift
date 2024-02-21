//
//  PayService.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import Foundation
import RxSwift
import RealmSwift
protocol PayProtocol{
    var event:PublishSubject<PayService.Event> {get}
    func getItemList()
    func validation(imp:String,merchant:String)
}
final class PayService: PayProtocol{
    var event: PublishSubject<Event> = .init()
    @DefaultsState(\.myInfo) var myInfo
    enum Event{
        case lists([PayAmountResponse])
        case bill(BillResponse)
        case error(PayFailed)
    }
    func getItemList(){
        Task{
            do{
                let res = try await NM.shared.itemList()
                event.onNext(.lists(res))
            }catch{
                print("payItemList Error!! \(error)")
            }
        }
    }
    func validation(imp:String,merchant:String){
        Task{
            do{
                let res = try await NM.shared.payValidation(imp: imp, merchant: merchant)
                print("validation: \(res)")
                self.myInfo?.sesacCoin += res.sesacCoin
                event.onNext(.bill(res))
            }catch{
                print("payValidation Error!! \(error)")
                if let payError = error as? PayFailed{
                    event.onNext(.error(payError))
                }
            }
        }
    }
}
