//
//  UINavigationController.swift
//  SolackProject
//
//  Created by 김태윤 on 1/11/24.
//

import UIKit
extension UINavigationController{
    func fullSheetSetting(){
        if let sheet = self.sheetPresentationController{
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.selectedDetentIdentifier = .large
            sheet.preferredCornerRadius = 10
        }
    }
}
