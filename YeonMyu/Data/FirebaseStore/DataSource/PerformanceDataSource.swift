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

    func removeReview(mt20id: String, reviewid: String) async throws {
        let performanceRef = db.collection("performanceReview").document(mt20id)
        let document = try await performanceRef.getDocument()
        guard let data = document.data() else { return }

        let updated = (data["reviews"] as? [[String: Any]] ?? [])
            .filter { $0["reviewid"] as? String != reviewid }

        try await performanceRef.updateData(["reviews": updated])
    }
}
