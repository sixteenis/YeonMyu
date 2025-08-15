//
//  PerformanceTagView.swift
//  YeonMyu
//
//  Created by 박성민 on 8/15/25.
//

import SwiftUI

struct PerformanceTagView: View {
    var tagTT: String
    
    init(tagTT: String) {
        self.tagTT = tagTT
    }
    
    var body: some View {
        asText(tagTT)
            .font(.font11)
            .foregroundStyle(Color.asWhite)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial) // 흐릿하게 비치는 배경
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.asWhite, lineWidth: 1) // 기존 테두리
                    )
            )
    }
}
