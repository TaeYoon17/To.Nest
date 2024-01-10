//
//  NewMessageBtn.swift
//  SolackProject
//
//  Created by 김태윤 on 1/7/24.
//

import UIKit
import SnapKit

final class NewMessageBtn: UIButton{
    init(){
        super.init(frame: .zero)
        self.setImage(.writeBtn, for: .normal)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
