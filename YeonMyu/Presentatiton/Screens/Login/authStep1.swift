//
//  AuthStep1.swift
//  YeonMyu
//
//  Created by 박성민 on 3/23/25.
//

import SwiftUI

struct AuthStep1: View {
    @EnvironmentObject var appCoordinator: MainCoordinator
    var uid: String
    @State private var selecedArea: CityCode?
    private let columns = [
        GridItem(.fixed(CGFloat(80)), spacing: 8),
        GridItem(.fixed(CGFloat(80)), spacing: 8),
        GridItem(.fixed(CGFloat(80)), spacing: 8),
        GridItem(.fixed(CGFloat(80)), spacing: 8),
    ]
    private let allCity = CityCode.allCases.filter { $0 != .all }
    
    var body: some View {
        NavigationView {
            VStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.asGray400)
                
                
                HStack(spacing: 12) {
                    asText("1")
                        .font(.font14)
                        .foregroundStyle(Color.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.asPurple300)
                        )
                    Circle()
                        .fill(Color.asGray400)
                        .frame(width: 12, height: 12)
                }
                .hCenter()
                .padding([.top, .bottom], 25)
                
                
                asText("어느 지역에 거주하시나요?")
                    .font(.boldFont20)
                    .bold()
                    .foregroundStyle(Color.asFont)
                    .padding(.bottom, 6)
                asText("주변의 공연을 추천해 드려요 ")
                    .font(.font16)
                    .foregroundStyle(Color.asGray200)
                    .padding(.bottom, 80)
                
                areaSelectView()
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(height: 50)
                        .foregroundStyle(selecedArea == nil ? Color.asGray400 : Color.asPurple300)
                    
                    asText("다음")
                        .font(.boldFont18)
                        .foregroundColor(selecedArea == nil ? Color.asGray300: Color.asWhite)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 15)
                .wrapToButton {
                    guard let area = selecedArea else { return }
                    appCoordinator.push(.authStep2(uid: uid, area: area.rawValue))
                }
            } //:VSTACK
        } //:NAVIGATION
    }
}
private extension AuthStep1 {
    func areaSelectView() -> some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(allCity, id: \.code) { city in
                asText(city.rawValue)
                    .font(.font16)
                    .foregroundStyle(city == selecedArea ? Color.asFont : Color.asGray300)
                    .frame(width: 80, height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(city == selecedArea ? Color.asPurple500 : Color.clear)
                            .stroke(city == selecedArea ? Color.asPurple300 : Color.asGray400, lineWidth: 2)
                    )
                    .wrapToButton {
                        if selecedArea == city {
                            selecedArea = nil
                        } else {
                            selecedArea = city
                        }
                    }
            }
        }
        .hCenter()
    }
}
#Preview {
    AuthStep1(uid: "")
}
