//
//  ReviewSetView.swift
//  YeonMyu
//
//  Created by 박성민 on 9/13/25.
//

import SwiftUI

struct ReviewSetView: View {
    @StateObject private var vm = ReviewSetVM()
    
    @State private var rating: Double = 1 //별점
    @State private var isReset = false
    
    private let performanceHighlights = ["음악", "연기", "스토리", "무대"]
    @State private var selectedPerformanceHighlights: [String] = []

    
    private let performanceFeelings = ["감동", "재미", "몰입", "공감", "에너지"]
    @State private var selectedPerformanceFeelings: [String] = []
    
    private let performanceEnvironments = ["음향", "조명", "좌석", "시야", "진행", "분위기"]
    @State private var selectedPerformanceEnvironments: [String] = []
    
    
    @State private var settingTT = ""
    @State private var reviewTT = ""
    let range: ClosedRange<Double> = 1...5
    var body: some View {
        content()
            .navigationTitle("후기 작성")
    }
    
    init(
        PreformanceData: SimplePerformance = SimplePerformance.getEmptyModel(),
        rating: Int = 1,
        highlights: [String] = [],
        feelings: [String] = [],
        environments: [String] = []
    ) {
        _rating = State(initialValue: Double(rating))
        _selectedPerformanceHighlights = State(initialValue: highlights)
        _selectedPerformanceFeelings = State(initialValue: feelings)
        _selectedPerformanceEnvironments = State(initialValue: environments)
    }
    
}

private extension ReviewSetView {
    func content() -> some View {
        ScrollView {
            LazyVStack {
                postInfoView()
                    .padding(.vertical, 10)
//                reSearchBtnView()
//                    .wrapToButton {
//                        print("재검색 클릭")
//                    }
                Rectangle()
                    .fill(Color.asGray600)
                    .frame(height: 6)
                    .padding(.horizontal, -24)
                
                reviewRatingView()
                
                performanceHighlightsView()
                performanceFeelingsView()
                performanceEnvironmentView()
                performanceSeatView()
                
                Rectangle()
                    .fill(Color.asGray600)
                    .frame(height: 6)
                    .padding(.horizontal, -24)
                
                performanceReViewView()
                    .padding(.bottom, 24)
                svaeBtnView()
                
            }
            .padding(.horizontal, 16)
        }
        
    }
}
// MARK: - 후기 상단 공연 정보 부분
private extension ReviewSetView {
    func postInfoView() -> some View {
        HStack {
            ZStack {
                Image.exPost
                    .resizable()
                
                PerformanceTagView(tagTT: "뮤지컬")
                    .hLeading()
                    .vTop()
                    .padding(6)
            }.frame(width: 92, height: 123)
            
            Spacer().frame(width: 20)
            
            VStack(alignment: .leading, spacing: 0) {
                asText("창작국악 어쩌구")
                    .font(.boldFont14)
                    .padding(.bottom, 15)
                    .padding(.top, 5)
                
                infoView(image: .calendarIcon, text: "2025년 7월 30일 (토)")
                infoView(image: .markerIcon, text: "국립극장 해오름극장")
            }
            .vTop()
        }
        .frame(height: 130)
    }
    func infoView(image: Image, text: String) -> some View {
        HStack(spacing: 2) {
            image
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.asGray300)
                .padding(.trailing, 2)
            asText(text)
                .lineLimit(1)
                .font(.font12)
                .foregroundStyle(Color.asGray300)
        }
        .hLeading()
    }
    func reSearchBtnView() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.asPurple500)
            .frame(height: 52)
            .overlay {
                HStack {
                    Image.search
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.asPurple300)
                    Text("공연 재검색")
                        .font(.boldFont16)
                        .foregroundStyle(Color.asPurple300)
                }
            }
        
    }
}

private extension ReviewSetView {
    func reviewRatingView() -> some View {
        VStack {
            asText("별점 선택")
                .font(.boldFont20)
                .padding(.bottom, 70)
                .padding(.top, 24)
                .hLeading()
            
            ItsukiSlider(value: $rating, in: range, step: 1, barStyle: (18, 10), fillBackground: Color.asGray400, fillTrack: Color.asPurple200) {
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 15)
        }
    }
    func performanceHighlightsView() -> some View {
        let columbs:[GridItem] =  [GridItem(.adaptive(minimum: 75))]
        return VStack {
            
            asText("좋았던 공연요소")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            LazyVGrid(columns: columbs, spacing: 6) {
                ForEach(performanceHighlights, id: \.self) { item in
                    selectedBox(
                        item,
                        isSelected: selectedPerformanceHighlights.contains(item)
                    ) {
                        toggleSelection(item, in: &selectedPerformanceHighlights)
                    }
                }
            }
            
        }
    }
    
    func performanceFeelingsView() -> some View {
        let columbs:[GridItem] =  [GridItem(.adaptive(minimum: 75))]
        return VStack {
            
            asText("느꼈던 감정/분위기")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            LazyVGrid(columns: columbs, spacing: 6) {
                ForEach(performanceFeelings, id: \.self) { item in
                    selectedBox(
                        item,
                        isSelected: selectedPerformanceFeelings.contains(item)
                    ) {
                        toggleSelection(item, in: &selectedPerformanceFeelings)
                    }
                }
            }
            
        }
    }
    func performanceEnvironmentView() -> some View {
        let columbs:[GridItem] =  [GridItem(.adaptive(minimum: 75))]
        return VStack {
            
            asText("만족한 관람환경")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            LazyVGrid(columns: columbs, spacing: 6) {
                ForEach(performanceEnvironments, id: \.self) { item in
                    selectedBox(
                        item,
                        isSelected: selectedPerformanceEnvironments.contains(item)
                    ) {
                        toggleSelection(item, in: &selectedPerformanceEnvironments)
                    }
                }
            }
            
        }
    }
    
    func performanceSeatView() -> some View {
        return VStack {
            
            asText("관람한 좌석")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            TextField("관람한 좌석을 알려주세요", text: $settingTT)
                .padding(12) // 안쪽 여백
                .background(Color.asGray500) // 원하는 배경색
                .cornerRadius(10) // 둥근 테두리
                .frame(height: 67)
            
        }
    }
    
    func performanceReViewView() -> some View {
        return VStack {
            
            asText("후기 입력")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            ZStack(alignment: .topLeading) {
                
                TextEditor(text: $reviewTT)
                    .scrollContentBackground(.hidden)
                    .frame(height: 230)
                    .padding(12)
                    .background(Color.asGray500)
                    .cornerRadius(10)
                
                if reviewTT.isEmpty {
                    Text("후기는 최대 1,000글자까지 작성 가능합니다.")
                        .foregroundColor(.asGray300)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
            }
        }
    }
    
    
    
    
    func selectedBox(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.asPurple500 : Color.asGray500)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.asMainPurpleBorderLine, lineWidth: isSelected ? 1 : 0)
                )
                .frame(height: 43)
                .overlay {
                    asText(title)
                        .font(.boldFont16)
                        .foregroundStyle(isSelected ? Color.asPurple300 : Color.asGray300)
                }
        }
        .buttonStyle(.plain)
    }
    func toggleSelection(_ item: String, in array: inout [String]) {
        if let index = array.firstIndex(of: item) {
            array.remove(at: index)
        } else {
            array.append(item)
        }
    }
    func svaeBtnView() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.asPurple300)
            .frame(height: 52)
            .overlay {
                    Text("후기 등록하기")
                        .font(.boldFont16)
                        .foregroundStyle(Color.asWhite)
            }
        
    }
}

#Preview {
    ReviewSetView()
}
