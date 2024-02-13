//
//  UIBarButtonItemExtensions.swift
//  SolackProject
//
//  Created by 김태윤 on 2/5/24.
//

import UIKit

extension UIBarButtonItem{
    static var getBackBtn: UIBarButtonItem{
        UIBarButtonItem(image: .init(systemName: "chevron.left",withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 17))))
    }
}
