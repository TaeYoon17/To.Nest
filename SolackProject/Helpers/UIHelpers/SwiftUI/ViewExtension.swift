//
//  ViewExtension.swift
//  SolackProject
//
//  Created by 김태윤 on 2/20/24.
//

import SwiftUI
extension View {
    func onReceiveForeground(_ closure: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)) { _ in
            print("Moving to the background!")
            closure()
        }
    }

    func onReceiveBackground(_ closure: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: UIScene.willDeactivateNotification)) { _ in
            print("Moving to the background!")
            closure()
        }
    }

    func onBackgroundDisappear(_ closure: @escaping () -> Void) -> some View {
        onReceiveBackground {
            print("onBackgroundDisappear :: onReceiveBackground!")
            closure()
        }.onDisappear {
            print("onBackgroundDisappear :: onDisappear!")
            closure()
        }
    }
}
