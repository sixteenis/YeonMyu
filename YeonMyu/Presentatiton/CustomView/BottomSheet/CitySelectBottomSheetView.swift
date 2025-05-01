//
//  CitySelectBottomSheetView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 3/3/25.
//

import SwiftUI

struct CitySelectBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedCity: CityCode
    @Binding var compltionCity: CityCode
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    let allCity = CityCode.allCases
    
    var body: some View {
        VStack(alignment: .leading) { // VStack을 leading 정렬
            asText("지역 선택")
                .font(.font20)
                .foregroundStyle(Color.asFont)
                .hLeading()
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(allCity, id: \.code) { city in
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 59, height: 35)
                        .foregroundStyle(city == selectedCity ? Color.asGray300 : Color.asGray400)
                        .overlay {
                            asText(city.rawValue)
                                .foregroundStyle(city == selectedCity ? Color.asWhite : Color.asGray200)
                        }
                        .wrapToButton {
                            selectedCity = city
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
            .padding(.horizontal, 20)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 50)
                    .foregroundStyle(Color.asPurple300)
                
                asText("완료")
                    .font(.boldFont18)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .wrapToButton {
                compltionCity = selectedCity
                dismiss()
            }
        }
        Spacer()
    }
}

