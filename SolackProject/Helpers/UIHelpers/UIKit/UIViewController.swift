//
//  UIViewController.swift
//  SolackProject
//
//  Created by 김태윤 on 2/14/24.
//

import UIKit
extension UIViewController{
    func coverAction(){
        let coverView = UIView()
        coverView.backgroundColor = .gray1
        self.view.addSubview(coverView)
        coverView.frame = self.view.bounds

        UIView.animate(withDuration: 0.5) {
            coverView.alpha = 0
        }completion: { _ in
            coverView.removeFromSuperview()
        }
    }
}
