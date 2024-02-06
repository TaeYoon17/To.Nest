//
//  ChatFields+TextViewDelegate.swift
//  SolackProject
//
//  Created by 김태윤 on 1/26/24.
//

import Foundation
import UIKit
extension MSGField.MSGTextField{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondary{
            textView.text = ""
            textView.textColor = .text
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = placeholder
            textView.textColor = .secondary
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        textPassthrough.onNext(textView.text)
        let size = CGSize(width: self.textField.frame.width, height: .infinity)
        let estimatedSize = self.textField.sizeThatFits(size)
        if nowHeight == estimatedSize.height { return }
        let isMaxHeight = estimatedSize.height >= textHeight * 3 + 4
        let height = min(estimatedSize.height,textHeight * 3 + 4)
        if height != prevHeight{
            self.needsUpdateCollectionViewLayout.onNext(())
            prevHeight = height
        }
        guard isMaxHeight != self.textField.isScrollEnabled else { return }
        self.textField.isScrollEnabled = isMaxHeight
        self.textField.reloadInputViews()
        self.textField.setNeedsUpdateConstraints()
    }
}
