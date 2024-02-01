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
    @MainActor func scrollAppend(yAxis:CGFloat,animated:Bool = false){
            let offset = CGFloat(floor(self.contentOffset.y + yAxis))
            let num = contentSize.height - self.bounds.size.height
            if self.contentOffset.y == num && yAxis < 0 { return }
            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: min(max(0,offset),num)), animated: animated)
        }
    @MainActor func scroll(yOffset:CGFloat){
        let num = contentSize.height - self.bounds.size.height
        self.setContentOffset(CGPoint(x: self.contentOffset.x, y: min(max(0,yOffset),num)), animated: false)
    }
    var isScrollable:Bool{
        self.bounds.height < self.contentSize.height
    }
}
