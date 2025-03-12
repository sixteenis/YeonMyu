//
//  HorizontalCalendarView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/12/24.
//

import SwiftUI

struct HorizontalCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var showSearch: Bool
    @Binding var searchText: String
    private let calendar = Calendar.current
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 10) {
                if showSearch {
                    searchView()
                        .frame(height: 30)
                } else {
                    monthView
                        .frame(height: 30)
                }
                Rectangle()
                    .fill(Color.background)
                    .clipShape(
                        .rect(
                            bottomLeadingRadius: 25,
                            bottomTrailingRadius: 25
                        )
                    )
                    .frame(height: 60)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 10)
                    .overlay (
                        ZStack {
                            dayView
                            blurView
                        }
                            .frame(height: 35)
                            .padding(.horizontal)
                    )
                
                
                
            }
        }
        .background(Color.asBackground)
    }
    private func searchView() -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 5)
            ZStack(alignment: .trailing) { // TextField 안에 X 버튼 배치
                TextField("공연 제목을 입력해 주세요.", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                
                // X 버튼을 TextField 안에 위치
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = "" // 버튼을 눌렀을 때 텍스트 초기화
                    }) {
                        Image.xMark
                            .foregroundColor(.gray)
                            .frame(width: 25, height: 25)
                    }
                    .padding(.trailing, 30) // 버튼의 위치 조정 (TextField 안에서 오른쪽 여백)
                }
            }
            .padding(.horizontal, 20) // 전체적으로 양쪽에 여백 추가
        }
    }
    
    private var monthView: some View {
        HStack(spacing: 10) {
            Button(
                action: {
                    changeMonth(-1)
                },
                label: {
                    Image(systemName: "chevron.left")
                        .asForeground(.asBlack)
                    
                }
            )
            
            Text(monthTitle(from: selectedDate))
                .font(.headline)
                .frame(width: 100)
            
            Button(
                action: {
                    changeMonth(1)
                },
                label: {
                    Image(systemName: "chevron.right")
                        .asForeground(.asBlack)
                }
            )
        }
    }
    
    // MARK: - 일자 표시 뷰
    @ViewBuilder
    private var dayView: some View {
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: selectedDate))!
        let components = (
            0..<calendar.range(of: .day, in: .month, for: startDate)!.count)
            .map {
                calendar.date(byAdding: .day, value: $0, to: startDate)!
            }
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 10) {
                    
                    
                    ForEach(components, id: \.self) { date in
                        VStack {
                            Text(day(from: date))
                                .font(.caption)
                            Text("\(calendar.component(.day, from: date))")
                        }
                        .frame(width: 30, height: 45)
                        .padding(5)
                        .background(calendar.isDate(selectedDate, equalTo: date, toGranularity: .day) ? Color.purple : Color.clear)
                        .cornerRadius(20)
                        .foregroundColor(calendar.isDate(selectedDate, equalTo: date, toGranularity: .day) ? .white : .black)
                        .id(date) // 각 날짜에 고유 id 할당
                        .onTapGesture {
                            selectedDate = date
                            // 날짜 선택 시 스크롤 중앙으로 이동
                            withAnimation {
                                proxy.scrollTo(date, anchor: .center)
                            }
                        }
                    }
                }
                
            }
            .onAppear {
                // Find the index of the selected date in the components array
                if let selectedIndex = components.firstIndex(where: { calendar.isDate(selectedDate, equalTo: $0, toGranularity: .day) }) {
                    // Scroll to the selected date
                    proxy.scrollTo(components[selectedIndex], anchor: .center)
                }
            }
        }
    }
    
    // MARK: - 블러 뷰
    private var blurView: some View {
        HStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.white.opacity(1),
                        Color.white.opacity(0)
                    ]
                ),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 20)
            .edgesIgnoringSafeArea(.leading)
            
            Spacer()
            
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.white.opacity(1),
                        Color.white.opacity(0)
                    ]
                ),
                startPoint: .trailing,
                endPoint: .leading
            )
            .frame(width: 20)
            .edgesIgnoringSafeArea(.leading)
        }
    }
}
// MARK: - 로직
private extension HorizontalCalendarView {
    /// 월 표시
    func monthTitle(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter.string(from: date)
    }
    
    /// 월 변경
    func changeMonth(_ value: Int) {
        guard let date = calendar.date(
            byAdding: .month,
            value: value,
            to: selectedDate
        ) else {
            return
        }
        
        selectedDate = date
    }
    
    /// 요일 추출
    func day(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.setLocalizedDateFormatFromTemplate("E")
        return dateFormatter.string(from: date)
    }
}

//#Preview {
//    HorizontalCalendarView()
//}
