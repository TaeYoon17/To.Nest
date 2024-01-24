//
//  ScreenSize.swift
//  SolackProject
//
//  Created by 김태윤 on 1/8/24.
//

import Foundation
import UIKit
extension UIWindow {
    @MainActor static var current: UIWindow? = {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }()
}


extension UIScreen {
    @MainActor static var current: UIScreen? = {
        UIWindow.current?.screen
    }()
}
