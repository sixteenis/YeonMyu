//
//  ReviewSetVM.swift
//  YeonMyu
//
//  Created by 박성민 on 10/29/25.
//

import Foundation

@MainActor
final class ReviewSetVM: ObservableObject {
    // MARK: - Constants
    let performanceHighlights = ["음악", "연기", "스토리", "무대"]
    let performanceFeelings = ["감동", "재미", "몰입", "공감", "에너지"]
    let performanceEnvironments = ["음향", "조명", "좌석", "시야", "진행", "분위기"]
    let ratingRange: ClosedRange<Double> = 1...5
    
    // MARK: - Published State
    @Published var rating: Double = 1
    @Published var selectedHighlights: Set<String> = []
    @Published var selectedFeelings: Set<String> = []
    @Published var selectedEnvironments: Set<String> = []
    @Published var seatText = ""
    @Published var reviewText = ""
    @Published var isSaving = false
    
    let postInfo: DetailPerformance
    
    // MARK: - Init
    init(
        postInfo: DetailPerformance,
        rating: Int = 1,
        highlights: [String] = [],
        feelings: [String] = [],
        environments: [String] = []
    ) {
        self.postInfo = postInfo
        self.rating = Double(rating)
        self.selectedHighlights = Set(highlights)
        self.selectedFeelings = Set(feelings)
        self.selectedEnvironments = Set(environments)
    }
    
    // MARK: - Actions
    func toggleItem(_ item: String, in selection: inout Set<String>) {
        if selection.contains(item) {
            selection.remove(item)
        } else {
            selection.insert(item)
        }
    }
    
    func saveReview(useCase: UserUseCase) async {
        isSaving = true
        defer { isSaving = false }
        
        let review = ReviewModel(
            reviewid: UUID().uuidString,
            mt20id: postInfo.mt20id,
            postType: postInfo.genrenm,
            rating: Int(rating),
            selectedPerformanceHighlights: Array(selectedHighlights),
            selectedPerformanceFeelings: Array(selectedFeelings),
            selectedPerformanceEnvironments: Array(selectedEnvironments),
            setting: seatText,
            review: reviewText,
            createdAt: Date()
        )
        
        do {
            try await useCase.writeReview(review)
        } catch {
            print("후기 저장 실패: \(error)")
        }
    }
}
