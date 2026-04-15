//
//  PerformanceDataSource.swift
//  YeonMyu
//
//  performanceReview 컬렉션에만 접근하는 DataSource

import Foundation
import FirebaseFirestore

final class PerformanceDataSource {
    private lazy var db = Firestore.firestore()
}

// MARK: - 후기
extension PerformanceDataSource {
    func addReview(_ review: ReviewModel) async throws {
        try await db.collection("performanceReview").document(review.mt20id).setData([
            "reviews": FieldValue.arrayUnion([review.toDictionary()])
        ], merge: true)
    }
    //공연별 리뷰 정보 가져오기
    func fetchReviews(mt20id: String) async throws -> [ReviewModel] {
        let document = try await db.collection("performanceReview").document(mt20id).getDocument()
        guard let data = document.data(),
              let reviews = data["reviews"] as? [[String: Any]] else { return [] }

        return reviews.compactMap { dict -> ReviewModel? in
            guard
                let reviewid = dict["reviewid"] as? String,
                let mt20id = dict["mt20id"] as? String,
                let postTitle = dict["postTitle"] as? String,
                let postType = dict["postType"] as? String,
                let rating = dict["rating"] as? Int,
                let highlights = dict["selectedPerformanceHighlights"] as? [String],
                let feelings = dict["selectedPerformanceFeelings"] as? [String],
                let environments = dict["selectedPerformanceEnvironments"] as? [String],
                let setting = dict["setting"] as? String,
                let review = dict["review"] as? String,
                let createdAt = (dict["createdAt"] as? Timestamp)?.dateValue(),
                let userID = dict["userID"] as? String,
                let userName = dict["userName"] as? String,
                let userProfileID = dict["userProfileID"] as? Int
            else { return nil }

            return ReviewModel(
                reviewid: reviewid,
                mt20id: mt20id,
                postTitle: postTitle,
                genreType: Genre.transform(str: postType),
                rating: rating,
                selectedPerformanceHighlights: highlights,
                selectedPerformanceFeelings: feelings,
                selectedPerformanceEnvironments: environments,
                setting: setting,
                review: review,
                createdAt: createdAt,
                userID: userID,
                userName: userName,
                userProfileID: userProfileID
            )
        }
    }

    func removeReview(mt20id: String, reviewid: String) async throws {
        let performanceRef = db.collection("performanceReview").document(mt20id)
        let document = try await performanceRef.getDocument()
        guard let data = document.data() else { return }

        let updated = (data["reviews"] as? [[String: Any]] ?? [])
            .filter { $0["reviewid"] as? String != reviewid }

        try await performanceRef.updateData(["reviews": updated])
    }
}
