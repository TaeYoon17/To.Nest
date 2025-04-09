//
//  LazyView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/20/24.
//

import SwiftUI

struct LazyView<Content: View> : View {
    var content:() -> Content
    init(content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        content()
    }
}
