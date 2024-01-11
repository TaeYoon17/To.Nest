//
//  BaseView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import UIKit
class BaseView: UIView{
    init(){
        super.init(frame: .zero)
        configureLayout()
        configureConstraints()
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    func configureView(){
        fatalError("Should be override")
    }
    func configureLayout(){
        fatalError("Should be override")
    }
    func configureConstraints(){
        fatalError("Should be override")
    }
}
