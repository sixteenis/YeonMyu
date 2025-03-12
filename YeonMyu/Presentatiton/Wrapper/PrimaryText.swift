//
//  PrimaryText.swift
//  SeSACSwiftUIBasic
//
//  Created by 박성민 on 8/27/24.
//

import SwiftUI

private struct PrimaryText: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.white)
            .padding()
            .cornerRadius(16)
    }
    

}

extension View {
    func asPrimaryText() -> some View {
        modifier(PrimaryText())
    }
}
