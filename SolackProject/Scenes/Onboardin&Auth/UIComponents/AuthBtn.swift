//
//  SignAccessoryBtn.swift
//  SolackProject
//
//  Created by 김태윤 on 1/6/24.
//

import SnapKit
import RxCocoa
import RxSwift
import UIKit

final class AuthBtn: UIButton{
    var isAvailable: Bool = false{
        didSet{
            let con = config.cornerRadius(10).foregroundColor(.white).text(text, font: .title2)
            con.backgroundColor(isAvailable ? .accent : .gray3).apply()
            self.isUserInteractionEnabled = isAvailable
        }
    }
    var text: String = ""{
        didSet{
            let con = config.cornerRadius(10).foregroundColor(.white).text(text, font: .title2)
            con.backgroundColor(isAvailable ? .accent : .gray3).apply()
            self.isUserInteractionEnabled = isAvailable
        }
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    init() {
        super.init(frame: .zero)
        let con = config.cornerRadius(10).foregroundColor(.white).text("회원가입", font: .title2)
        con.backgroundColor(isAvailable ? .accent : .gray3).apply()
        self.isUserInteractionEnabled = false
    }
}
