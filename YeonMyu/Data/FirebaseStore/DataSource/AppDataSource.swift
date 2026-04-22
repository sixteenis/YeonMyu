//
//  PerformanceRankingDataSource.swift
//  YeonMyu
//
//  Created by psm on 4/13/26.
//

import Foundation
import FirebaseFirestore

final class AppDataSource {
    private lazy var db = Firestore.firestore()
}

// MARK: - 랭킹 조회/업데이트
extension AppDataSource {
    private var rankingRef: DocumentReference {
        db.collection("appData").document("performanceRanking")
    }
    
    private var recentReviewRef: DocumentReference {
        db.collection("appData").document("recentReview")
    }
    // 공연 탑 10 조회
    func fetchRanking() async throws -> (updateDate: Date?, ranking: [SimplePostModel]) {
        let document = try await rankingRef.getDocument()
        guard let data = document.data() else { return (nil, []) }

        let updateDate = (data["updateDate"] as? Timestamp)?.dateValue()
        let ranking = (data["ranking"] as? [[String: Any]] ?? []).map {
            SimplePostModel(
                postId: $0["mt20id"] as? String ?? "",
                postURL: "",
                postType: $0["postType"] as? String ?? "",
                postTitle: $0["postTitle"] as? String ?? "",
                startDate: "",
                endDate: "",
                location: ""
            )
        }
        return (updateDate, ranking)
    }

    func updateRanking(items: [SimplePostModel]) async throws {
        let rankingData: [[String: Any]] = items.map {
            ["mt20id": $0.mt20id, "postTitle": $0.postTitle, "postType": $0.postType]
        }
        try await rankingRef.setData([
            "updateDate": Timestamp(),
            "ranking": rankingData
        ])
    }
}
// MARK: - 최근 리뷰
extension AppDataSource {
    // 리뷰 저장 (최신 10개 유지)
    func saveRecentReview(_ review: ReviewModel) async throws {
        let document = try await recentReviewRef.getDocument()
        var reviews = (document.data()?["reviews"] as? [[String: Any]]) ?? []
        reviews.insert(review.toDictionary(), at: 0)
        if reviews.count > 10 { reviews = Array(reviews.prefix(10)) }
        try await recentReviewRef.setData(["reviews": reviews])
    }

    // 최근 리뷰에서 특정 리뷰 삭제 (포함된 경우에만)
    func removeRecentReviewIfExists(reviewid: String) async throws {
        let document = try await recentReviewRef.getDocument()
        guard let reviews = document.data()?["reviews"] as? [[String: Any]],
              reviews.contains(where: { $0["reviewid"] as? String == reviewid })
        else { return }
        let updated = reviews.filter { $0["reviewid"] as? String != reviewid }
        try await recentReviewRef.setData(["reviews": updated])
    }

    // 최근 리뷰 10개 조회
    func fetchRecentReviews() async throws -> [ReviewModel] {
        let document = try await recentReviewRef.getDocument()
        guard let list = document.data()?["reviews"] as? [[String: Any]] else { return [] }
        return list.compactMap { ReviewModel(dict: $0) }
    }
}

