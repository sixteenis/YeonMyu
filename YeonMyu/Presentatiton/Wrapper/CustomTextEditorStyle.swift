//
//  CustomTextEditorStyle.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/28/24.
//
import SwiftUI

struct CustomTextEditorStyle: ViewModifier {
    
    let placeholder: String
    @Binding var text: String
    
    func body(content: Content) -> some View {
            content
                .padding(15)
                .background(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .lineSpacing(10)
                            .padding(20)
                            .padding(.top, 2)
                            .font(.system(size: 14))
                            .foregroundColor(Color(UIColor.systemGray2))
                    }
                }
                .textInputAutocapitalization(.none) // 첫 시작 대문자 막기
                .autocorrectionDisabled()
                .background(Color.grayBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .scrollContentBackground(.hidden)
                .font(.font14)
                .overlay(alignment: .bottomTrailing) {
                    Text("\(text.count) / 100")
                        .font(.system(size: 12))
                        .foregroundColor(Color(UIColor.systemGray2))
                        .padding(.trailing, 15)
                        .padding(.bottom, 15)
                        .onChange(of: text) { newValue in
                            if newValue.count > 100 {
                                text = String(newValue.prefix(100))
                            }
                        }
                }
    }
}

extension TextEditor {
    func customStyleEditor(placeholder: String, userInput: Binding<String>) -> some View {
        self.modifier(CustomTextEditorStyle(placeholder: placeholder, text: userInput))
    }
}
