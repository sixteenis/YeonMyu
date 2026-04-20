//
//  ReviewDetailView.swift
//  YeonMyu
//
//  Created by psm on 4/15/26.
//

import SwiftUI

struct ReviewDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    @Environment(UserUseCase.self) private var userUseCase
    private let reviewInfo: ReviewModel
    private let isShowMovePerfInfo: Bool
    @State private var perfInfo: DetailPerformance? = nil
    @State private var isLoading = false
    private var isReviewOwner: Bool { reviewInfo.userID == userUseCase.userInfo.uid }
    init(reviewInfo: ReviewModel, isShowMovePerfInfo: Bool) {
        self.reviewInfo = reviewInfo
        self.isShowMovePerfInfo = isShowMovePerfInfo
    }

    var body: some View {
        content()
            .navigationTitle(isReviewOwner ? "관람후기" : "내 후기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if (isReviewOwner) {
                        Button {
                            print("삭제 버튼 클릭")
                            Task {
                                
                                coordinator.presentAlert(.deleteReview {
                                    Task {
                                        isLoading = true
                                        try? await userUseCase.deleteReview(reviewInfo)
//                                        coordinator.showToast(.simple(message: "후기가 삭제되었습니다.", icon: .asCheckingIcon))
                                        dismiss()
                                        isLoading = false
                                    }
                                    
                                })

                                
                                
                            }
                        } label: {
                            Image.asTrash
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundStyle(Color.asNewGray800)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .task {
                isLoading = true
                let dto = try? await NetworkManager.shared.requestDetailPerformance(performanceId: reviewInfo.mt20id)
                perfInfo = dto?.transformDetailModel()
                isLoading = false
            }
            .overlay {
                if isLoading { LoadingView().ignoresSafeArea() }
            }
    }
}

private extension ReviewDetailView {
    func content() -> some View {
        ScrollView {
            LazyVStack {
                postInfoSection
                    .padding(.vertical, 10)
                if isShowMovePerfInfo {
                    //공연 정보 보로가기 버튼
                    Button {
                        // Action
                        coordinator.push(.playDetail(mt20id: reviewInfo.mt20id))
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .asForeground(Color.asNewGray200)
                            .overlay {
                                asText("공연 정보 보로가기")
                                    .asForeground(Color.asNewGray700)
                                    .font(.boldFont18)
                            }
                    }
                    .frame(height: 56)
                    .padding(.bottom, 12)
                }
                sectionDivider
                
                ratingSection
                
                tagDisplaySection(
                    title: "좋았던 공연요소",
                    items: reviewInfo.selectedPerformanceHighlights
                )
                tagDisplaySection(
                    title: "느꼈던 감정/분위기",
                    items: reviewInfo.selectedPerformanceFeelings
                )
                tagDisplaySection(
                    title: "만족한 관람환경",
                    items: reviewInfo.selectedPerformanceEnvironments
                )
                
                seatInputSection
                
                sectionDivider
                
                reviewInputSection
                    .padding(.bottom, 24)
                

            }
            .padding(.horizontal, 16)
        }
    }
}
// MARK: - 공연 정보 섹션
private extension ReviewDetailView {
    var postInfoSection: some View {
        HStack {
            ZStack {
                PosterImageView(url: perfInfo?.posterURL ?? "")
                    .frame(width: 92, height: 123)

                PerformanceTagView(tagTT: reviewInfo.genreType.tagText, tagType: .opacity)
                    .hLeading()
                    .vTop()
                    .padding(6)
            }
            .frame(width: 92, height: 123)

            Spacer().frame(width: 20)

            VStack(alignment: .leading, spacing: 0) {
                asText(perfInfo?.name ?? reviewInfo.postTitle)
                    .font(.boldFont14)
                    .lineLimit(2)
                    .padding(.bottom, 15)
                    .padding(.top, 5)

                infoRow(image: .calendarIcon, text: perfInfo?.playDate ?? "")
                infoRow(image: .markerIcon, text: perfInfo?.place ?? "")
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
private extension ReviewDetailView {
    var ratingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            asText("별점")
                .font(.boldFont20)
                .padding(.top, 24)

            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { index in
                    if index <= reviewInfo.rating {
                        Image.asFillRoundStar
                            .resizable()
                            .frame(width: 36, height: 36)
                    } else {
                        Image.asRoundStar
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                }
            }
        }
        .hLeading()
    }
}

// MARK: - 태그 표시 섹션
private extension ReviewDetailView {
    func tagDisplaySection(title: String, items: [String]) -> some View {
        let columns = [GridItem(.adaptive(minimum: 75))]
        return VStack {
            asText(title)
                .font(.boldFont20)
                .padding(.bottom, 12)
                .padding(.top, 24)
                .hLeading()

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.asPurple500)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.asMainPurpleBorderLine, lineWidth: 1)
                        )
                        .frame(height: 43)
                        .overlay {
                            asText(item)
                                .font(.boldFont16)
                                .foregroundStyle(Color.asPurple300)
                        }
                }
            }
        }
    }
}

// MARK: - 좌석 & 후기 입력 섹션
private extension ReviewDetailView {
    var seatInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            asText("관람한 좌석")
                .font(.boldFont20)
                .padding(.top, 24)

            asText(reviewInfo.setting.isEmpty ? "-" : reviewInfo.setting)
                .font(.font16)
                .foregroundColor(.asText)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 67, alignment: .topLeading)
//                .background(Color.asGray500)
//                .cornerRadius(10)
        }
    }

    var reviewInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            asText("후기")
                .font(.boldFont20)
                .padding(.top, 24)

            asText(reviewInfo.review.isEmpty ? "-" : reviewInfo.review)
                .font(.font16)
                .foregroundColor(.asText)
                .padding(12)
                .frame(maxWidth: .infinity, minHeight: 230, alignment: .topLeading)
//                .background(Color.asGray500)
//                .cornerRadius(10)
        }
    }
}

// MARK: - 공통 UI
private extension ReviewDetailView {
    var sectionDivider: some View {
        Rectangle()
            .fill(Color.asGray600)
            .frame(height: 6)
            .padding(.horizontal, -24)
    }
    

}
