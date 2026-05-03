//
//  AppError.swift
//  Domain Layer - 도메인 통합 에러
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 핵심 원칙
//   "ViewModel/View 는 URLError, FirestoreErrorCode 를 절대 보지 않는다."
//
//   - URLError, NSError, FirestoreErrorCode 같은 저수준 타입은 외부 라이브러리의 언어.
//   - SwiftUI View 가 그걸 직접 다루면 → 라이브러리 교체 시 모든 View 수정.
//   - 그래서 Data 레이어가 "도메인 언어(AppError)" 로 번역해서 위로 올린다.
//
//  📌 두 종류의 에러
//   - AppError       : 외부 시스템과 상호작용 결과 (네트워크/서버/인증/형식)
//   - ValidationError: 사용자 입력 검증 (별도. 예: 닉네임 비었음)
//                      이건 화면 컨텍스트 강해서 각 화면이 자체 정의해도 OK.
//
//  📌 scope 의 의미
//   - .global: 어떤 화면에서 발생하든 동일 UI 로 처리 (오프라인/서버 장애/인증 만료)
//   - .local : 발생한 화면이 자체 처리 (해당 자원 없음/형식 오류 등)
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation

enum AppError: Error, Equatable {

    /// 인터넷 연결 끊김. 재시도 의미 있음.
    case offline

    /// 401/403 — 인증 만료/거부. 보통 로그인 화면 유도.
    case unauthorized

    /// 404 / 자원 없음 — 이미 삭제된 항목 등.
    case notFound

    /// 5xx — 서버 측 일시적 문제. 재시도 의미 있음.
    case serverUnavailable

    /// 429 — Rate limit.
    case rateLimited(retryAfter: TimeInterval?)

    /// 디코딩/파싱 실패 — 보통 클라이언트/서버 스키마 mismatch.
    case decodingFailed

    /// Firebase Firestore 권한/설정 오류.
    case permissionDenied

    /// 위 분류에 안 맞는 모든 것. 원인은 로깅용으로 보존.
    case unknown(underlying: String)

    // MARK: - View 가 사용할 정보

    /// 사용자에게 보여 줄 메시지. View 는 이걸 그대로 alert/toast 로 띄움.
    var userMessage: String {
        switch self {
        case .offline:
            return "인터넷 연결을 확인해 주세요."
        case .unauthorized:
            return "로그인이 필요해요."
        case .notFound:
            return "해당 데이터를 찾을 수 없어요."
        case .serverUnavailable:
            return "서버에 일시적인 문제가 있어요.\n잠시 후 다시 시도해 주세요."
        case .rateLimited(let after):
            if let after { return "요청이 너무 많아요. \(Int(after))초 후 다시 시도해 주세요." }
            return "요청이 너무 많아요. 잠시 후 다시 시도해 주세요."
        case .decodingFailed:
            return "데이터를 읽을 수 없어요.\n앱을 최신 버전으로 업데이트해 주세요."
        case .permissionDenied:
            return "접근 권한이 없어요."
        case .unknown:
            return "일시적인 오류가 발생했어요.\n잠시 후 다시 시도해 주세요."
        }
    }

    /// 자동 재시도 의미 여부.
    var isRetryable: Bool {
        switch self {
        case .offline, .serverUnavailable, .rateLimited:
            return true
        case .unauthorized, .notFound, .decodingFailed, .permissionDenied, .unknown:
            return false
        }
    }

    /// 처리 범위.
    var scope: ErrorScope {
        switch self {
        case .offline, .serverUnavailable, .unauthorized, .rateLimited:
            return .global
        case .notFound, .decodingFailed, .permissionDenied, .unknown:
            return .local
        }
    }
}

enum ErrorScope {
    case global
    case local
}
