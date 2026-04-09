//
//  ReviewSetView.swift
//  YeonMyu
//
//  Created by 박성민 on 9/13/25.
//

import SwiftUI

struct ReviewSetView: View {
    @Environment(UserUseCase.self) private var userUseCase
    @StateObject private var vm: ReviewSetVM
    
    init(
        postID: String,
        rating: Int = 1,
        highlights: [String] = [],
        feelings: [String] = [],
        environments: [String] = []
    ) {
        _vm = StateObject(wrappedValue: ReviewSetVM(
            postID: postID,
            rating: rating,
            highlights: highlights,
            feelings: feelings,
            environments: environments
        ))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                postInfoSection
                    .padding(.vertical, 10)
                
                sectionDivider
                
                ratingSection
                
                tagSelectionSection(
                    title: "좋았던 공연요소",
                    items: vm.performanceHighlights,
                    selection: $vm.selectedHighlights
                )
                tagSelectionSection(
                    title: "느꼈던 감정/분위기",
                    items: vm.performanceFeelings,
                    selection: $vm.selectedFeelings
                )
                tagSelectionSection(
                    title: "만족한 관람환경",
                    items: vm.performanceEnvironments,
                    selection: $vm.selectedEnvironments
                )
                
                seatInputSection
                
                sectionDivider
                
                reviewInputSection
                    .padding(.bottom, 24)
                
                saveButton
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("후기 작성")
    }
}

// MARK: - 공연 정보 섹션
private extension ReviewSetView {
    var postInfoSection: some View {
        HStack {
            ZStack {
                Image.exPost
                    .resizable()
                
                PerformanceTagView(tagTT: "뮤지컬")
                    .hLeading()
                    .vTop()
                    .padding(6)
            }
            .frame(width: 92, height: 123)
            
            Spacer().frame(width: 20)
            
            VStack(alignment: .leading, spacing: 0) {
                asText("창작국악 어쩌구")
                    .font(.boldFont14)
                    .padding(.bottom, 15)
                    .padding(.top, 5)
                
                infoRow(image: .calendarIcon, text: "2025년 7월 30일 (토)")
                infoRow(image: .markerIcon, text: "국립극장 해오름극장")
            }
            .vTop()
        }
        .frame(height: 130)
    }
    
    func infoRow(image: Image, text: String) -> some View {
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
}

// MARK: - 별점 섹션
private extension ReviewSetView {
    var ratingSection: some View {
        VStack {
            asText("별점 선택")
                .font(.boldFont20)
                .padding(.bottom, 70)
                .padding(.top, 24)
                .hLeading()
            
            ItsukiSlider(
                value: $vm.rating,
                in: vm.ratingRange,
                step: 1,
                barStyle: (18, 10),
                fillBackground: Color.asGray400,
                fillTrack: Color.asPurple200
            ) {
                Circle()
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
            }
            .padding(.leading, 15)
        }
    }
}

// MARK: - 태그 선택 섹션 (재사용 컴포넌트)
private extension ReviewSetView {
    func tagSelectionSection(
        title: String,
        items: [String],
        selection: Binding<Set<String>>
    ) -> some View {
        let columns = [GridItem(.adaptive(minimum: 75))]
        return VStack {
            asText(title)
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    tagChip(
                        item,
                        isSelected: selection.wrappedValue.contains(item)
                    ) {
                        vm.toggleItem(item, in: &selection.wrappedValue)
                    }
                }
            }
        }
    }
    
    func tagChip(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
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
}

// MARK: - 좌석 & 후기 입력 섹션
private extension ReviewSetView {
    var seatInputSection: some View {
        VStack {
            asText("관람한 좌석")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            TextField("관람한 좌석을 알려주세요", text: $vm.seatText)
                .padding(12)
                .background(Color.asGray500)
                .cornerRadius(10)
                .frame(height: 67)
        }
    }
    
    var reviewInputSection: some View {
        VStack {
            asText("후기 입력")
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $vm.reviewText)
                    .scrollContentBackground(.hidden)
                    .frame(height: 230)
                    .padding(12)
                    .background(Color.asGray500)
                    .cornerRadius(10)
                
                if vm.reviewText.isEmpty {
                    Text("후기는 최대 1,000글자까지 작성 가능합니다.")
                        .foregroundColor(.asGray300)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
        }
    }
}

// MARK: - 공통 UI
private extension ReviewSetView {
    var sectionDivider: some View {
        Rectangle()
            .fill(Color.asGray600)
            .frame(height: 6)
            .padding(.horizontal, -24)
    }
    
    var saveButton: some View {
        Button {
            Task { await vm.saveReview(useCase: userUseCase) }
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.asPurple300)
                .frame(height: 52)
                .overlay {
                    if vm.isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("후기 등록하기")
                            .font(.boldFont16)
                            .foregroundStyle(Color.asWhite)
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(vm.isSaving)
    }
}
