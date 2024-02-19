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
}
final class PayService: PayProtocol{
    var event: PublishSubject<Event> = .init()
    enum Event{
        case lists([PayAmountResponse])
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
}
