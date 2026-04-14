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
