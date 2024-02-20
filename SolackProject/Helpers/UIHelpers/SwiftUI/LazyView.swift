//
//  LazyView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/20/24.
//

import SwiftUI

struct LazyView<c:View>:View{
    var content:() -> c
    init(content: @escaping () -> c) {
        self.content = content
    }
    var body: some View{
        content()
    }
}
