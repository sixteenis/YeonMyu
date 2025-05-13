//
//  TotalSelectBottomSheetView.swift
//  YeonMyu
//
//  Created by 박성민 on 5/7/25.
//

import SwiftUI
enum TicketPriceEnum: String, CaseIterable {
    case all = "가격 전체"
    case under30000 = "3만원 이하"
    case between30000And70000 = "3~7만원"
    case between70000And100000 = "7~10만원"
    case over100000 = "10만원 이상"
    
    var priceRange: ClosedRange<Int> {
        switch self {
        case .all: 0...0
        case .under30000: 0...30_000
        case .between30000And70000: 30_000...70_000
        case .between70000And100000: 70_000...100_000
        case .over100000: 100_000...100_000_000
            
        }
    }
}
struct TotalSelectBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var compltionDate: Date
    @Binding var compltionCity: CityCode
    @Binding var compltionTicketEnum: TicketPriceEnum?
    @Binding var compltionPrice: ClosedRange<Int>?
    
    @State private var selecetedDate: Date
    @State private var selectedCity: CityCode
    @State private var selectTicketEnum: TicketPriceEnum?
    @State private var selectPrice: ClosedRange<Int>?
    
    @State private var value: ClosedRange<Double> = 50_000...150_000
    let range: ClosedRange<Double> = 10_000...300_000
    let segments: [String]
    
    
    @State var selectPage = 0
    private let oneSegmentWidth: CGFloat = 50
    private let sheetHeight: CGFloat = 300
    private let priceList = TicketPriceEnum.allCases
    
    private let allCity = CityCode.allCases
    init(selected: Int ,compltionDate: Binding<Date>, compltionCity: Binding<CityCode>, compltionPriceEnum: Binding<TicketPriceEnum?>, compltionPrice: Binding<ClosedRange<Int>?>) {
        self.selectPage = selected
        self._selecetedDate = State(initialValue: compltionDate.wrappedValue)
        self._compltionDate = compltionDate
        
        self._selectedCity = State(initialValue: compltionCity.wrappedValue)
        self._compltionCity = compltionCity
        
        self._selectTicketEnum = State(initialValue: compltionPriceEnum.wrappedValue)
        self._compltionTicketEnum = compltionPriceEnum
        
        self._selectPrice = State(initialValue: compltionPrice.wrappedValue)
        self._compltionPrice = compltionPrice
        
        self.segments =  ["날짜", "지역", "가격대"]
    }
    init(selected: Int ,compltionDate: Binding<Date>, compltionCity: Binding<CityCode>) {
        self.selectPage = selected
        self._selecetedDate = State(initialValue: compltionDate.wrappedValue)
        self._compltionDate = compltionDate
        
        self._selectedCity = State(initialValue: compltionCity.wrappedValue)
        self._compltionCity = compltionCity
        
        self._compltionTicketEnum = .constant(nil)
        self._compltionPrice = .constant(nil)
        self.segments =  ["날짜", "지역"]
    }
    var body: some View {
        stickyHeader()
            .hLeading()
            .padding(.leading, 24)
            .padding(.vertical, 12)
        switch selectPage {
        case 0: dateSelectView().frame(height: sheetHeight)
        case 1: citySelectView().frame(height: sheetHeight)
        case 2: priceSelectView().frame(height: sheetHeight)
        default: EmptyView().frame(height: sheetHeight)
        }
        
        //확인 버튼
        HStack(spacing: 0) {
            Button {
                // Action
                selecetedDate = compltionDate
                selectedCity = compltionCity
                selectTicketEnum = compltionTicketEnum
                selectPrice  = compltionPrice
                
            } label: {
                Rectangle()
                    .fill(Color.asGray400)
                    .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                    .overlay {
                        asText("필터 초기화")
                            .foregroundStyle(Color.asGray300)
                            .font(.boldFont18)
                    }
            }
            Button {
                compltionDate = selecetedDate
                compltionCity = selectedCity
                compltionTicketEnum = selectTicketEnum
                if compltionTicketEnum == nil {
                    compltionPrice = selectTicketEnum?.priceRange
                } else {
                    compltionPrice = Int(value.lowerBound)...Int(value.upperBound)
                }
                
                dismiss()
                
            } label: {
                Rectangle()
                    .fill(Color.asPurple300)
                    .cornerRadius(12, corners: [.topRight, .bottomRight])
                    .overlay {
                        asText("적용하기")
                            .foregroundStyle(Color.asWhite)
                            .font(.boldFont18)
                    }
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 22)
        .vBottom()
        
    }
}
private extension TotalSelectBottomSheetView {
    func stickyHeader() -> some View {
        VStack {
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(segments.indices, id: \.self) { index in
                        Button {
                            print("Tapped segment: \(index)")
                            selectPage = index
                        } label: {
                            ZStack {
                                asText(segments[index])
                                    .font(.boldFont16)
                                    .foregroundColor(selectPage == index ? Color.asFont : Color.asGray300)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                            }
                            
                        }
                    }
                }
                .frame(width: oneSegmentWidth*CGFloat(segments.count), height: 4)
                Rectangle()
                    .frame(width: oneSegmentWidth / 1.3, height: 2)
                    .foregroundStyle(Color.asFont)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.2), value: selectPage)
                    .offset(x: CGFloat(selectPage) * (oneSegmentWidth) + 7, y: -6)
                    .vBottom()
            }
            .frame(height: 40)
        }
        .background(Color.asWhite)
    }
    //날짜 선택
    func dateSelectView() -> some View {
//        VStack {
            DatePicker(
                "Start Date",
                selection: $selecetedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "ko_KR")) // ✅ 한국어 적용
            .tint(Color.asPurple300)
            .padding(.horizontal, 24)
            .frame(maxHeight: 200)
            
//        }.vTop()
    }
    //지역 선택
    func citySelectView() -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        return LazyVGrid(columns: columns, spacing: 12) {
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
        .vTop()
    }
    //가격 선택
    func priceSelectView() -> some View {
        VStack {
            FlowLayout(spacing: 10, lineSpacing: 10) {
                ForEach(priceList, id: \.self) { price in
                    HStack(spacing: 4) {
                        
                        Text(price.rawValue)
                            .font(.font16)
                            .foregroundStyle(selectTicketEnum == price ? Color.asGray400 : Color.asGray300)
                            .frame(maxWidth: 80)
                        
                    }
                    .padding(.horizontal, 16) // 좌우 여백 추가
                    .padding(.vertical, 8)   // 상하 여백 추가
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(selectTicketEnum == price ? Color.asGray300 : Color.asGray400)
                    )
                    .wrapToButton {
                        selectTicketEnum = price
                        selectPrice = price.priceRange
                        //금액 선택 시 이벤트 구현
                    }
                }
                //사용자 선택 버튼 부분
                HStack(spacing: 4) {
                    Image.asSlider
                        .resizable()
                        .foregroundStyle(selectPrice == nil ? Color.asGray400 : Color.asGray300)
                        .frame(width: 20, height: 20)
                    Text("직접 선택")
                        .font(.font16)
                        .foregroundStyle(selectPrice == nil ? Color.asGray400 : Color.asGray300)
                    
                }
                .padding(.horizontal, 16) // 좌우 여백 추가
                .padding(.vertical, 8)   // 상하 여백 추가
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(selectPrice == nil ? Color.asGray300 : Color.asGray400)
                )
                .wrapToButton {
                    selectTicketEnum = nil
//                    selectPrice = Int(value.lowerBound)...Int(value.upperBound)
                    //금액 선택 시 이벤트 구현
                }
            }
            .hLeading()
            .padding(.leading, 24)
            if selectTicketEnum == nil {
                sliderView()
                    .padding(.top, 36)
                    .padding(.horizontal, 24)
            }
            
        }.vTop()
    }
    func sliderView() -> some View {
        VStack {
            HStack {
                asText("10,000원")
                    .font(.font14)
                    .foregroundStyle(Color.asGray200)
                    
                Spacer()
                
                asText("300,000원")
                    .font(.font14)
                    .foregroundStyle(Color.asGray200)
            }
            .padding(.bottom, 10)
            
            ItsukiSlider(value: $value, in: range, step: 100, barStyle: (18, 10), fillBackground: Color.asGray400, fillTrack: Color.asPurple200, firstThumb: {
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                
            }, secondThumb: {
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
            })
            
            Text("\(Int(value.lowerBound).formatted())원 ~ \(Int(value.upperBound).formatted())원")
                .font(.boldFont20)
                .foregroundStyle(Color.asPurple200)
                .hCenter()
                .padding(.top, 24)
        }
    }
    
}
#Preview {
    TotalSelectBottomSheetView(selected: 0, compltionDate: .constant(Date()), compltionCity: .constant(.busan), compltionPriceEnum: .constant(nil), compltionPrice: .constant(0...1000))
}
