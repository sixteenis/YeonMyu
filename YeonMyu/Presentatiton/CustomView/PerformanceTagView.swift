//
//  PerformanceTagView.swift
//  YeonMyu
//
//  Created by 박성민 on 8/15/25.
//

import SwiftUI

enum TagType {
    case opacity //투명
    case normal // 기본
}
struct PerformanceTagView: View {
    var tagTT: String
    var tagType: TagType
    init(tagTT: String, tagType: TagType) {
        self.tagTT = tagTT
        self.tagType = tagType
    }
    
    var body: some View {
        asText(tagTT)
            .font(.font12)
            .foregroundStyle(tagType == .opacity ? Color.asWhite : Color.asNewGray600)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(tagType == .opacity ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.clear))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(tagType == .opacity ? Color.asWhite : Color.asNewGray600, lineWidth: 1)
                    )
            )
    }
}
