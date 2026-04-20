//
//  ReviewSetView.swift
//  YeonMyu
//
//  Created by 박성민 on 9/13/25.
//

import SwiftUI

struct ReviewWriteView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    @Environment(UserUseCase.self) private var userUseCase
    
    @StateObject private var vm: ReviewWriteVM
    
    init(
        postInfo: DetailPerformance,
        rating: Int = 1,
        highlights: [String] = [],
        feelings: [String] = [],
        environments: [String] = []
    ) {
        _vm = StateObject(wrappedValue: ReviewWriteVM(
            postInfo: postInfo,
            rating: rating,
            highlights: highlights,
            feelings: feelings,
            environments: environments
        ))
    }
    
    var body: some View {
        content()
            .navigationTitle("후기 작성")
            .overlay {
                if vm.isSaving {
                    LoadingView()
                        .ignoresSafeArea()
                }
            }
            .onChange(of: vm.showValidationAlert) { oldValue, newValue in
                coordinator.presentAlert(.validation(title: vm.validationMessage,  action: {
                    print("검증 실패 알림 확인누름")
                }))
            }
            .onChange(of: vm.saveState) { oldValue, newValue in
                switch newValue {
                case .success:
                    coordinator.presentAlert(.saveReviewSuccess(action: {
                        coordinator.showToast(.reviewMove(action: {
                                coordinator.pushAndReset(.tab)
                                coordinator.changeTab(tab: .my)
                            }))
                        dismiss()
                    }))
                case .failure:
                    coordinator.presentAlert(.networkError(action: {
                        vm.saveState = .idle
                        print("후기 작성 과정에서 오류 발생")
                    }))
                case .idle:
                    break
                }
                
            }
    }
}

private extension ReviewWriteView {
    func content() -> some View {
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
    }
}
// MARK: - 공연 정보 섹션
private extension ReviewWriteView {
    var postInfoSection: some View {
        HStack {
            ZStack {
                PosterImageView(url: vm.postInfo.posterURL)
                    .frame(width: 92, height: 123)
                
                PerformanceTagView(tagTT: vm.postInfo.genreType.tagText, tagType: .opacity)
                    .hLeading()
                    .vTop()
                    .padding(6)
            }
            .frame(width: 92, height: 123)
            
            Spacer().frame(width: 20)
            
            VStack(alignment: .leading, spacing: 0) {
                asText(vm.postInfo.name)
                    .font(.boldFont14)
                    .lineLimit(2)
                    .padding(.bottom, 15)
                    .padding(.top, 5)
                
                infoRow(image: .calendarIcon, text: vm.postInfo.playDate)
                infoRow(image: .markerIcon, text: vm.postInfo.place)
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
private extension ReviewWriteView {
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
private extension ReviewWriteView {
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
private extension ReviewWriteView {
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
private extension ReviewWriteView {
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
                        HStack(alignment: .center, spacing: 6) {
                            Image.asCheckingIcon
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(Color.asWhite)
                                .frame(width: 28, height: 28)
                            
                            Text("작성 완료")
                                .font(.boldFont16)
                                .foregroundStyle(Color.asWhite)
                        }
                    }
                }
        }
        .buttonStyle(.plain)
        .disabled(vm.isSaving)
    }
}
