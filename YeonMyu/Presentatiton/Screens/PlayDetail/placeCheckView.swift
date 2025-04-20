//
//  placeCheckView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/13/25.
//

import SwiftUI

struct placeCheckView: View {
    private let columns = [
        GridItem(.fixed(CGFloat(80)), spacing: 8),
        GridItem(.fixed(CGFloat(80)), spacing: 8),
        GridItem(.fixed(CGFloat(80)), spacing: 8),
    ]
    private let allCity = CityCode.allCases
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(allCity, id: \.code) { city in
                HStack(spacing: 4) {
                    Image.asCheck
                        .resizable()
                        .foregroundStyle(Color.asPurple300)
                        .frame(width: 20, height: 20)
                    asText(city.rawValue)
                        .font(.font16)
                }
                .frame(width: 90)
                .hLeading()
            }
        }
        //        .hCenter()
    }
}

#Preview {
    placeCheckView()
}
