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
//    @MainActor func moveToFrame(contentOffset : CGFloat,axis: ScrollType) {
//        switch axis{
//        case .x:
//            let num = contentSize.width - self.bounds.size.width
//            self.setContentOffset(CGPoint(x: min(max(0,contentOffset),num), y: self.contentOffset.y), animated: true)
//        case .y:
//            let num = contentSize.height - self.bounds.size.height
//            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: min(max(0,contentOffset),num)), animated: true)
//        }
//    }
    @MainActor func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: false)
        }
    }
}
