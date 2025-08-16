//
//  GradientBackground.swift
//  YeonMyu
//
//  Created by 박성민 on 8/16/25.
//

import SwiftUI

struct GradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color(hex: "D7A6FF"), Color(hex: "6CA2FF")],
                    startPoint: .topLeading,
                    endPoint: .trailing
                )
            )
    }
}

extension View {
    func gradientBackground() -> some View {
        self.modifier(GradientBackground())
    }
}
