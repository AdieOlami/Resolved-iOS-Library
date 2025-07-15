//
//  View+If.swift
//  ResolvedLibrary
//
//  Created by Olami on 2025-07-14.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
