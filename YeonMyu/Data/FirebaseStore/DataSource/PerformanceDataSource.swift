//
//  PerformanceDataSource.swift
//  YeonMyu
//
//  공연 관련 모든 데이터에 접근하는 DataSource (KOPIS API + Firebase)

import Foundation
import FirebaseFirestore

final class PerformanceDataSource {
    private lazy var db = Firestore.firestore()
}

// MARK: - 후기
extension PerformanceDataSource {
    func addReview(_ review: ReviewModel) async throws {
        try await db.collection("performanceReview").document(review.mt20id).loggedSetData([
            "reviews": FieldValue.arrayUnion([review.toDictionary()])
        ], merge: true)
    }
    //공연별 리뷰 정보 가져오기
    func fetchReviews(mt20id: String) async throws -> [ReviewModel] {
        let document = try await db.collection("performanceReview").document(mt20id).loggedGetDocument()
        guard let data = document.data(),
              let reviews = data["reviews"] as? [[String: Any]] else { return [] }
        return reviews.compactMap { ReviewModel(dict: $0) }
    }

    func removeReview(mt20id: String, reviewid: String) async throws {
        let performanceRef = db.collection("performanceReview").document(mt20id)
        let document = try await performanceRef.loggedGetDocument()
        guard let data = document.data() else { return }

        let updated = (data["reviews"] as? [[String: Any]] ?? [])
            .filter { $0["reviewid"] as? String != reviewid }

        try await performanceRef.loggedUpdateData(["reviews": updated])
    }
}

// MARK: - KOPIS 네트워크
extension PerformanceDataSource {
    func fetchPerformances(
        startDate: String,
        endDate: String? = nil,
        cateCode: String = "",
        area: String? = nil,
        title: String = "",
        page: Int = 1,
        openrun: Bool = false,
        maxOnePage: String = "10"
    ) async throws -> [PerformanceDTO] {
        try await NetworkManager.shared.requestPerformance(
            startDate: startDate, endDate: endDate, cateCode: cateCode,
            area: area, title: title, page: page, openrun: openrun, maxOnePage: maxOnePage
        )
    }

    func fetchDetailPerformance(id: String) async throws -> DetailPerformanceDTO {
        try await NetworkManager.shared.requestDetailPerformance(performanceId: id)
    }

    func fetchFacility(id: String) async throws -> FacilityDTO {
        try await NetworkManager.shared.requestFacility(facilityId: id)
    }

    func fetchBoxOffice(startDate: String, endDate: String, cateCode: String, area: String?) async throws -> [BoxOfficeDTO] {
        try await NetworkManager.shared.requestBoxOffice(startDate: startDate, endDate: endDate, cateCode: cateCode, area: area)
    }

    func fetchAward(startDate: String, endDate: String, cateCode: String? = nil, area: String? = nil, page: Int? = nil) async throws -> [AwadPerformanceDTO] {
        try await NetworkManager.shared.requestAwad(startDate: startDate, endDate: endDate, cateCode: cateCode, area: area, page: page)
    }
}
