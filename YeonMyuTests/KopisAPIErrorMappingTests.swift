//
//  KopisAPIErrorMappingTests.swift
//  YeonMyuTests
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 무엇을 검증하나
//   1. KopisAPIError → AppError 매핑이 의도대로 분류되는가
//   2. URLError / Firestore NSError → AppError 매핑
//   3. AppError 의 scope, isRetryable, userMessage 의 일관성
//   4. CancellationError 등 외부 에러가 특정 케이스로 떨어지는지
//
//  📌 왜 매핑 함수가 1순위 테스트 대상인가
//   - 외부 API 의 status 코드와 도메인 에러의 매핑 규칙은 시간이 갈수록 변형되기 쉬움
//   - 한 줄이라도 매핑이 잘못되면 사용자에게 잘못된 메시지/잘못된 화면 분기
//   - 테스트가 있으면 미래의 회귀 자동 차단
//  ─────────────────────────────────────────────────────────────────────────
//

import XCTest
@testable import YeonMyu

final class KopisAPIErrorMappingTests: XCTestCase {

    // MARK: - HTTP status 매핑

    func test_http401_mapsTo_unauthorized() {
        XCTAssertEqual(KopisAPIError.http(status: 401).asAppError, .unauthorized)
    }

    func test_http403_mapsTo_unauthorized() {
        XCTAssertEqual(KopisAPIError.http(status: 403).asAppError, .unauthorized)
    }

    func test_http404_mapsTo_notFound() {
        XCTAssertEqual(KopisAPIError.http(status: 404).asAppError, .notFound)
    }

    func test_http429_mapsTo_rateLimited() {
        XCTAssertEqual(KopisAPIError.http(status: 429).asAppError, .rateLimited(retryAfter: nil))
    }

    func test_http500_mapsTo_serverUnavailable() {
        XCTAssertEqual(KopisAPIError.http(status: 500).asAppError, .serverUnavailable)
    }

    func test_http503_mapsTo_serverUnavailable() {
        XCTAssertEqual(KopisAPIError.http(status: 503).asAppError, .serverUnavailable)
    }

    func test_http418_mapsTo_unknown() {
        // 분류되지 않은 status 는 unknown 으로
        if case .unknown = KopisAPIError.http(status: 418).asAppError { /* OK */ } else {
            XCTFail("418 should map to .unknown")
        }
    }

    // MARK: - URLError 매핑 (offline 분류)

    func test_notConnectedToInternet_mapsTo_offline() {
        XCTAssertEqual(KopisAPIError.transport(URLError(.notConnectedToInternet)).asAppError, .offline)
    }

    func test_networkConnectionLost_mapsTo_offline() {
        XCTAssertEqual(KopisAPIError.transport(URLError(.networkConnectionLost)).asAppError, .offline)
    }

    func test_timedOut_mapsTo_offline() {
        XCTAssertEqual(KopisAPIError.transport(URLError(.timedOut)).asAppError, .offline)
    }

    func test_dataNotAllowed_mapsTo_offline() {
        XCTAssertEqual(KopisAPIError.transport(URLError(.dataNotAllowed)).asAppError, .offline)
    }

    func test_unsupportedURL_mapsTo_unknown() {
        // offline 분류에 안 들어가는 URLError 는 unknown
        if case .unknown = KopisAPIError.transport(URLError(.unsupportedURL)).asAppError {
            // OK
        } else {
            XCTFail("unsupportedURL should map to .unknown")
        }
    }

    // MARK: - 그 외 KopisAPIError

    func test_invalidURL_mapsTo_unknown() {
        if case .unknown = KopisAPIError.invalidURL.asAppError { /* OK */ } else {
            XCTFail("invalidURL should map to .unknown")
        }
    }

    func test_parseFailed_mapsTo_decodingFailed() {
        XCTAssertEqual(KopisAPIError.parseFailed.asAppError, .decodingFailed)
    }

    // MARK: - asAppError() (Error 확장) — 임의 에러를 AppError 로

    func test_existingAppError_passesThrough() {
        // 이미 AppError 면 그대로
        let error: Error = AppError.offline
        XCTAssertEqual(error.asAppError(), .offline)
    }

    func test_kopisError_routedThroughTopLevel() {
        let error: Error = KopisAPIError.http(status: 401)
        XCTAssertEqual(error.asAppError(), .unauthorized)
    }

    func test_urlError_directlyMapped() {
        // KopisAPIError 로 감싸지지 않은 URLError 도 변환되어야 함
        let error: Error = URLError(.notConnectedToInternet)
        XCTAssertEqual(error.asAppError(), .offline)
    }

    func test_firestorePermissionDenied_mapsTo_permissionDenied() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 7, userInfo: nil)
        XCTAssertEqual(error.asAppError(), .permissionDenied)
    }

    func test_firestoreUnavailable_mapsTo_serverUnavailable() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 14, userInfo: nil)
        XCTAssertEqual(error.asAppError(), .serverUnavailable)
    }

    func test_firestoreUnauthenticated_mapsTo_unauthorized() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 16, userInfo: nil)
        XCTAssertEqual(error.asAppError(), .unauthorized)
    }

    func test_firestoreNotFound_mapsTo_notFound() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 5, userInfo: nil)
        XCTAssertEqual(error.asAppError(), .notFound)
    }

    func test_unknownNSError_mapsTo_unknown() {
        let error = NSError(domain: "Unknown", code: 999, userInfo: nil)
        if case .unknown = error.asAppError() { /* OK */ } else {
            XCTFail("Unknown NSError should map to .unknown")
        }
    }
}

// MARK: - AppError 자체 속성 검증

final class AppErrorTests: XCTestCase {

    // MARK: - scope

    func test_offline_isGlobalScope() {
        XCTAssertEqual(AppError.offline.scope, .global)
    }

    func test_unauthorized_isGlobalScope() {
        XCTAssertEqual(AppError.unauthorized.scope, .global)
    }

    func test_serverUnavailable_isGlobalScope() {
        XCTAssertEqual(AppError.serverUnavailable.scope, .global)
    }

    func test_rateLimited_isGlobalScope() {
        XCTAssertEqual(AppError.rateLimited(retryAfter: nil).scope, .global)
    }

    func test_notFound_isLocalScope() {
        XCTAssertEqual(AppError.notFound.scope, .local)
    }

    func test_decodingFailed_isLocalScope() {
        XCTAssertEqual(AppError.decodingFailed.scope, .local)
    }

    func test_permissionDenied_isLocalScope() {
        XCTAssertEqual(AppError.permissionDenied.scope, .local)
    }

    func test_unknown_isLocalScope() {
        XCTAssertEqual(AppError.unknown(underlying: "x").scope, .local)
    }

    // MARK: - isRetryable

    func test_offline_isRetryable() {
        XCTAssertTrue(AppError.offline.isRetryable)
    }

    func test_serverUnavailable_isRetryable() {
        XCTAssertTrue(AppError.serverUnavailable.isRetryable)
    }

    func test_rateLimited_isRetryable() {
        XCTAssertTrue(AppError.rateLimited(retryAfter: 5).isRetryable)
    }

    func test_unauthorized_isNotRetryable() {
        // 토큰 갱신 없이 무한 재시도해도 의미 없음
        XCTAssertFalse(AppError.unauthorized.isRetryable)
    }

    func test_notFound_isNotRetryable() {
        XCTAssertFalse(AppError.notFound.isRetryable)
    }

    func test_decodingFailed_isNotRetryable() {
        // 스키마 mismatch 는 재시도해도 그대로
        XCTAssertFalse(AppError.decodingFailed.isRetryable)
    }

    // MARK: - userMessage 비어있지 않음

    func test_userMessage_isNonEmpty_forAllCases() {
        let cases: [AppError] = [
            .offline, .unauthorized, .notFound, .serverUnavailable,
            .rateLimited(retryAfter: nil), .rateLimited(retryAfter: 30),
            .decodingFailed, .permissionDenied,
            .unknown(underlying: "x")
        ]
        for error in cases {
            XCTAssertFalse(error.userMessage.isEmpty,
                           "userMessage should not be empty for \(error)")
        }
    }

    // MARK: - Equatable 동작

    func test_rateLimited_equality() {
        XCTAssertEqual(
            AppError.rateLimited(retryAfter: 30),
            AppError.rateLimited(retryAfter: 30)
        )
        XCTAssertNotEqual(
            AppError.rateLimited(retryAfter: 30),
            AppError.rateLimited(retryAfter: nil)
        )
    }

    func test_unknown_equality_byUnderlying() {
        XCTAssertEqual(
            AppError.unknown(underlying: "a"),
            AppError.unknown(underlying: "a")
        )
        XCTAssertNotEqual(
            AppError.unknown(underlying: "a"),
            AppError.unknown(underlying: "b")
        )
    }
}
