//
//  WriterConfiguration.swift
//  SolackProject
//
//  Created by 김태윤 on 1/16/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa
import Toast

protocol WritableView{
    func apply(config:WriterConfigureation)
}
struct WriterConfigureation{
    var buttonText:String = ""
    lazy var mainField:InputFieldView.Configuration = .init(field: "", placeholder: "", keyType: .default, accessoryText: buttonText)
    lazy var descriptionField:InputFieldView.Configuration = .init(field: "", placeholder: "", keyType: .default, accessoryText: buttonText)
    var navigationTitle:String = ""
    var isAvaileScrollClose:Bool = false
}
