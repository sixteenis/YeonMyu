//
//  SourceAndAppInfoView.swift
//  YeonMyu
//
//  Created by psm on 4/22/26.
//

import SwiftUI

struct SourceAndAppInfoView : View {
    var body: some View {
        Rectangle()
            .overlay {
                VStack {
                    Image.logoS
                        .resizable()
                        .foregroundStyle(Color.asGray300)
                        .frame(width: 108, height: 22)
                        .padding(.bottom, 12)
                    
                    Text("공연정보 출처")
                        .font(.font12)
                        .foregroundStyle(Color.asGray300)
                    Link(destination: URL(string: "https://www.kopis.or.kr")!) {
                        Text("(재)예술경영지원센터 공연예술통합전산망")
                            .font(.font12)
                            .foregroundStyle(Color.asGray300)
                    }
                    
                }
            }
            .foregroundStyle(Color.asBorderGray)
            .frame(height: 160)
    }
}



