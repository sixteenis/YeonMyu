//
//  ReviewSetView.swift
//  YeonMyu
//
//  Created by 박성민 on 9/13/25.
//

import SwiftUI

struct ReviewSetView: View {
    @State private var value: Double = 1
    @State private var isReset = false
    let range: ClosedRange<Double> = 1...5
    var body: some View {
        content()
            .navigationTitle("후기 작성")
    }
}

private extension ReviewSetView {
    func content() -> some View {
        ScrollView {
            LazyVStack {
                postInfoView()
                    .padding(.vertical, 10)
                reSearchBtnView()
                    .wrapToButton {
                        print("재검색 클릭")
                    }
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
            Image.exPost
                .resizable()
                .frame(width: 92, height: 123)
            
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
                        .frame(width: 22, height: 22)
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
            
            ItsukiSlider(value: $value, in: range, step: 1, barStyle: (18, 10), fillBackground: Color.asGray400, fillTrack: Color.asPurple200) {
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
                ForEach(0...10, id: \.self) { index in
                    selectedBox(index.formatted())
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
                ForEach(0...10, id: \.self) { index in
                    selectedBox(index.formatted())
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
                ForEach(0...10, id: \.self) { index in
                    selectedBox(index.formatted())
                }
            }
            
        }
    }
    
    func performanceSeatView() -> some View {
        @State var seatTT = ""
        return VStack {
            
            asText("관람한 좌석")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            TextField("관람한 좌석을 알려주세요", text: $seatTT)
                .padding(12) // 안쪽 여백
                .background(Color.asGray500) // 원하는 배경색
                .cornerRadius(10) // 둥근 테두리
                .frame(height: 67)
            
        }
    }
    
    func performanceReViewView() -> some View {
        @State var seatTT = ""
        return VStack {
            
            asText("후기 입력")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            ZStack(alignment: .topLeading) {
                if seatTT.isEmpty {
                    Text("관람한 후기를 알려주세요")
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $seatTT)
                    .scrollContentBackground(.hidden)
                    .frame(height: 230)
                    .padding(12)
                    .background(Color.asGray500)
                    .cornerRadius(10)
            }
        }
    }
    
    
    
    
    func selectedBox(_ title: String) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.asPurple500)
            .stroke(Color.asMainPurpleBorderLine, lineWidth: 1)
            .frame(height: 43)
            .overlay {
                asText(title)
                    .font(.boldFont16)
                    .foregroundStyle(Color.asPurple300)
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
