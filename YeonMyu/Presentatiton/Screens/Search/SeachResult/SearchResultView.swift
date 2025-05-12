//
//  SearchResultView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/21/25.
//


import SwiftUI

struct SearchResultView: View {
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    @State private var searchText: String
    @State private var searchCity: CityCode
    @State private var searchDate: Date
    @State private var searchPrice: ClosedRange<Int>? = nil
    
    
    init(searchText: String, date: Date, city: CityCode) {
        self.searchText = searchText
        self.searchCity = city
        self.searchDate = date
        
    }
    
}

extension SearchResultView {
    var body: some View {
        contentView()
    }
}
private extension SearchResultView {
    func contentView() -> some View {
        VStack {
            Text(searchText)
            Button {
                // Action
                print("???")
                coordinator.presentSheet(.totalSelect(selected: 0, date: $searchDate, city: $searchCity, price: $searchPrice))
            } label: {
                Text("??")
            }
            HStack {
                optionView(searchDate.asTrasnFormyy_mm_dd())
                    .wrapToButton {
                        coordinator.presentSheet(.totalSelect(selected: 0, date: $searchDate, city: $searchCity, price: $searchPrice))
                    }
                optionView(searchCity.rawValue)
                    .wrapToButton {
                        coordinator.presentSheet(.totalSelect(selected: 1, date: $searchDate, city: $searchCity, price: $searchPrice))
                    }
                optionView(searchPrice == nil ? "가격대" : "\(searchPrice?.lowerBound ?? 0)~\(searchPrice?.upperBound ?? 0)")
                    .wrapToButton {
                        coordinator.presentSheet(.totalSelect(selected: 2, date: $searchDate, city: $searchCity, price: $searchPrice))
                    }
                
            }
        }
    }
}
private extension SearchResultView {
    func optionView(_ title: String) -> some View {
        HStack(spacing: 0) {
            asText(title)
            Image.downArrow
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.asGray300)
//                .rotationEffect(.degrees(isAreSelectedPresented ? 180 : 0)) // 180도 회전
//                .animation(.easeInOut(duration: 0.15), value: isAreSelectedPresented) // 애니메이션 적용
                .padding(.leading, 2)
                .padding(.trailing, 4)
        }
        .font(.boldFont20)
        .foregroundStyle(Color.asGray300)
        .padding(.leading, 10)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.asGray500)
                .stroke(Color.asGray300, lineWidth: 1.5)
        )
    }
}
