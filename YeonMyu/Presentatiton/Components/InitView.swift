//
//  InitView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/26/25.
//

import SwiftUI


struct InitView: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(Color.asPurple300)
            .overlay {
                VStack {
                    Image.logoM
                        .resizable()
                        .frame(width: 166.67, height: 34)
                    asText("연극과 뮤지컬, 더 가까이 더 깊이")
                }
            }
    }
}
