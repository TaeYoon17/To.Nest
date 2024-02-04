//
//  AppFont.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import Foundation
import UIKit
import SwiftUI
enum FontType{
    case title1
    case title2
    case bodyBold
    case body
    case caption
    case caption2
    func action( text:String) -> NSAttributedString{
        switch self{
        case .body: text.body
        case .bodyBold: text.bodyBold
        case .caption: text.caption
        case .caption2:text.caption2
        case .title1: text.title1
        case .title2: text.title2
        }
    }
    func get() -> UIFont{
        switch self{
        case .body:
            UIFont(name: "SFPro-Regular", size: 13)!
        case .bodyBold:
            UIFont(name: "SFPro-Bold", size: 13)!
        case .caption:
            UIFont(name: "SFPro-Regular", size: 12)!
        case .title1:
            UIFont(name: "SFPro-Bold", size: 22)!
        case .title2:
            UIFont(name: "SFPro-Bold", size: 14)!
        case .caption2:
            UIFont(name: "SFPro-Regular", size: 11)!
        }
    }
    var font: Font{
        switch self{
        case .body: Font.custom("SFPro-Regular", size: 13)
        case .bodyBold: Font.custom("SFPro-Bold", size: 13)
        case .caption: Font.custom("SFPro-Regular", size: 12)
        case .caption2: Font.custom("SFPro-Regular", size: 11)
        case .title1: Font.custom("SFPro-Bold", size: 22)
        case .title2: Font.custom("SFPro-Bold", size: 14)
        }
    }
}
extension String{
    
    private func maker(font: UIFont,line:CGFloat)->NSAttributedString{
        
        let style = NSMutableParagraphStyle()
        style.maximumLineHeight = line
        style.minimumLineHeight = line

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .baselineOffset: (line - font.lineHeight) / 2
        ]
        
        let attrString = NSAttributedString(string: self,
                                            attributes: attributes)
        return attrString
    }
    var title1:NSAttributedString{
        maker(font: FontType.title1.get(), line: 30)
    }
    var title2: NSAttributedString{
        maker(font: FontType.title2.get(), line: 20)
    }
    var bodyBold: NSAttributedString{
        maker(font: FontType.bodyBold.get(), line: 18)
    }
    var body: NSAttributedString{
        maker(font: FontType.body.get(), line: 18)
    }
    var caption: NSAttributedString{
        maker(font: FontType.caption.get(), line: 18)
    }
    var caption2: NSAttributedString{
        maker(font: FontType.caption2.get(), line: 18)
    }
    func attr(type:FontType) -> AttributedString{
        
        var attr :AttributedString = AttributedString(self)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let font = type.get()
        attr.font = font
//        let line:CGFloat = switch type{
//        case .bodyBold, .caption,.body: 18
//        case .title1: 30
//        case .title2: 20
//        case .caption2: 18
//        }
//        paragraphStyle.minimumLineHeight = line
//        paragraphStyle.maximumLineHeight = line
//        attr.paragraphStyle = paragraphStyle
//        attr.baselineOffset = (line - font.lineHeight) / 2
        return attr
    }
}

private struct FontWithLineHeight: ViewModifier {
    let font: UIFont
    let lineHeight: CGFloat
    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
}

extension View {
    private func fontWithLineHeight(font: UIFont, lineHeight: CGFloat) -> some View {
        ModifiedContent(content: self, modifier: FontWithLineHeight(font: font, lineHeight: lineHeight))
    }
    var title1: some View{
        self.fontWithLineHeight(font: .systemFont(ofSize: 22, weight: .bold), lineHeight: 40)
    }
    var title2: some View{
        self.fontWithLineHeight(font: .systemFont(ofSize: 14, weight: .bold), lineHeight: 20)
    }
    var bodyBold: some View{
        self.fontWithLineHeight(font: .systemFont(ofSize: 13, weight: .bold), lineHeight: 18)
    }
    var body: some View{
        self.fontWithLineHeight(font: .systemFont(ofSize: 13, weight: .regular), lineHeight: 18)
    }
    var caption: some View{
        self.fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .regular), lineHeight: 18)
    }
}
