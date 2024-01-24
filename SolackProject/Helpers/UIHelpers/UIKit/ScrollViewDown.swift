//
//  ScrollViewDown.swift
//  SolackProject
//
//  Created by 김태윤 on 1/20/24.
//

import Foundation
import UIKit
extension UICollectionView{
    enum ScrollType{
        case x
        case y
    }
}
extension UICollectionView{
    @MainActor func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: false)
        }
    }
}
