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

typealias CHReactrable = WriterReactor<CHFailed, CHToastType>
class CHWriterReactor:WriterReactor<CHFailed, CHToastType>{
    override func writerTransform(state: Observable<CHReactrable.State>) -> Observable<CHReactrable.State> {
        fatalError("Must be override!!")
    }
    override func writerTransformtransform(mutation: Observable<WriterReactor<CHFailed, CHToastType>.Mutation>) -> Observable<WriterReactor<CHFailed, CHToastType>.Mutation> {
        fatalError("Must be override!!")
    }
}
