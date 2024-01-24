//
//  CHWriterReactor.swift
//  SolackProject
//
//  Created by 김태윤 on 1/15/24.
//

import Foundation
import RxSwift
import ReactorKit
import UIKit
enum CHToastType:ToastType{
    case wow,hello
    var contents: String{
        "asdfs"
    }
    var getColor: UIColor{
        UIColor.black
    }
}
typealias CHReactrable = WriterReactor<CHFailed, CHToastType>
final class CHWriterReactor:WriterReactor<CHFailed, CHToastType>{
    
    override func mutate(action: CHReactrable.Action) -> Observable<CHReactrable.Mutation> {
        switch action{
        case .confirmAction:
            return Observable.concat([])
        case .setDescription(let description):
            return .just(.setDescription(description))
        case .setName(let name):
            return .just(.setName(name))
        }
    }
    override func writerTransform(state: Observable<CHReactrable.State>) -> Observable<CHReactrable.State> {
        Observable.concat([])
    }
    override func writerTransformtransform(mutation: Observable<WriterReactor<CHFailed, CHToastType>.Mutation>) -> Observable<WriterReactor<CHFailed, CHToastType>.Mutation> {
        Observable.concat([])
    }
}
