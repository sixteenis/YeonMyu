//
//  PerformanceRepository.swift
//  Domain Layer - 공연 정보 저장소 추상
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 왜 protocol 을 별도로 두는가?
//   - UseCase 는 "어디서 데이터가 오는지" 모르고, "이런 일은 할 수 있어야 한다" 만 안다.
//   - 구현체(PerformanceDataSource = KOPIS API + Firestore)를 갈아끼우거나
//     테스트용 Mock 으로 바꿀 수 있게 해 줌.
//
//  📌 기존 코드와의 관계
//   - 기존 `PerformanceDataSource` 클래스는 그대로 두고, 이 프로토콜만 채택.
//   - UseCase 가 새 init 으로 PerformanceRepository 를 받게 변경 (Phase 5).
//   - 호출지 변경 없음 (메서드 시그니처 동일).
//
//  📌 DTO 가 protocol 시그니처에 등장하는 이유
//   - 기존 시스템이 transform() 으로 Domain 변환을 UseCase 에서 처리.
//   - 점진 마이그레이션 위해 일단 시그니처를 유지.
//   - 추후엔 protocol 이 Domain 모델만 노출하도록 정제 가능.
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation

protocol PerformanceRepository: AnyObject {

    // MARK: - KOPIS

    func fetchPerformances(
        startDate: String,
        endDate: String?,
        cateCode: String,
        area: String?,
        title: String,
        page: Int,
        openrun: Bool,
        maxOnePage: String
    ) async throws -> [PerformanceDTO]

    func fetchDetailPerformance(id: String) async throws -> DetailPerformanceDTO

    func fetchFacility(id: String) async throws -> FacilityDTO

    func fetchBoxOffice(
        startDate: String,
        endDate: String,
        cateCode: String,
        area: String?
    ) async throws -> [BoxOfficeDTO]

    func fetchAward(
        startDate: String,
        endDate: String,
        cateCode: String?,
        area: String?,
        page: Int?
    ) async throws -> [AwadPerformanceDTO]

    // MARK: - Firestore (공연별 리뷰)

    func addReview(_ review: ReviewModel) async throws
    func fetchReviews(mt20id: String) async throws -> [ReviewModel]
    func removeReview(mt20id: String, reviewid: String) async throws
}

// MARK: - 호출 편의 (default arg)
//
// Swift protocol 자체에는 default 인자를 둘 수 없지만,
// protocol extension 으로 default 인자가 있는 래퍼 메서드를 제공할 수 있다.
// → 기존 호출지가 일부 인자만 넘기던 패턴이 그대로 동작.

extension PerformanceRepository {
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
        try await fetchPerformances(
            startDate: startDate, endDate: endDate, cateCode: cateCode,
            area: area, title: title, page: page, openrun: openrun, maxOnePage: maxOnePage
        )
    }

    func fetchAward(
        startDate: String,
        endDate: String,
        cateCode: String? = nil,
        area: String? = nil,
        page: Int? = nil
    ) async throws -> [AwadPerformanceDTO] {
        try await fetchAward(
            startDate: startDate, endDate: endDate,
            cateCode: cateCode, area: area, page: page
        )
    }
}

// MARK: - 기존 DataSource 가 채택

extension PerformanceDataSource: PerformanceRepository {}
