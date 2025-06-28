//
// Copyright (c) Beyoug
//

import SwiftUI
import Foundation

// MARK: - 扩展方法

extension View {
    /// 条件性应用修饰符
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
