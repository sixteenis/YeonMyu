//
//  EmptyView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/24/26.
//

import SwiftUI


struct PostEmptyView: View {
    let infoText: String
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image.asEmpty
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200, alignment: .center)
            asText(infoText)
                .font(.font16)
                .foregroundStyle(Color.asGray300)
                .multilineTextAlignment(.center)
            
        }
    }
}
