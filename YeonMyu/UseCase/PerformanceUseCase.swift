//
//  PerformanceUseCase.swift
//  YeonMyu
//
//  Created by 박성민 on 4/8/26.
//

import Foundation

final class PerformanceUseCase {
    private let userDS = UserDataSource()
    private let performanceDS = PerformanceDataSource()

    init() {}
    
    // 공연별 리뷰 정보 가져오기
    func getReviewData(_ postId: String) async throws -> [ReviewModel] {
        let reviews = try await performanceDS.fetchReviews(mt20id: postId)
        return reviews
    }
}
