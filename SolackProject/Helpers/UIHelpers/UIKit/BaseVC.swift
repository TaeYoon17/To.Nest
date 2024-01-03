//
//  BaseVC.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import UIKit
class BaseVC: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureNavigation()
        configureConstraints()
        configureView()
    }
    func configureLayout(){ }
    func configureConstraints(){ }
    func configureView(){ }
    func configureNavigation(){ }
}
