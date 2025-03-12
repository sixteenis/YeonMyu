//
//  ButtonWrapper.swift
//  SeSACSwiftUIBasic
//
//  Created by 박성민 on 8/28/24.
//

import SwiftUI

private struct ButtonWrapper: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        Button {
            action()
            
        } label: {
            content
        }
    }
}
extension View {
    func wrapToButton(action: @escaping () -> Void) -> some View {
        modifier(ButtonWrapper(action: action))
    }
}
