//
//  KopisAPIError.swift
//  Data Layer - KOPIS API 저수준 에러 (Data 내부에서만 사용)
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 두 단계 에러 모델
//   - KopisAPIError : Data 내부 (정확한 원인 정보)
//   - AppError      : Domain (위로 올라가는 도메인 언어)
//
//   변환은 NetworkManager 안에서 매핑 함수 한 곳으로만.
//
//  📌 기존 PerformanceError 와의 관계
//   - 기존 PerformanceError 는 4 케이스만 (invalidURL/invalidResponse/...).
//   - 그대로 두면 호환성 있고, 점진적으로 KopisAPIError 가 그걸 흡수/대체.
//   - 한 번에 PerformanceError 사용처를 다 못 바꾸므로, Phase 3 단계에서는
//     매핑을 추가하는 데만 집중하고, throw 호출지는 다음 phase 에 정리.
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation

enum KopisAPIError: Error {
    /// URL 자체를 만들 수 없음. 코드 버그.
    case invalidURL

    /// URLSession 에서 throw 한 URLError 전반 (오프라인/타임아웃 등).
    case transport(URLError)

    /// HTTP 응답은 받았지만 상태 코드가 2xx 가 아님.
    case http(status: Int)

    /// XML 파싱 실패 (KOPIS 는 XML 응답).
    case parseFailed
}

// MARK: - AppError 매핑
//
// Data 와 Domain 의 경계. 모든 저수준 에러는 여기서 한 번 번역되고,
// 그 후로는 AppError 만 위로 올라간다.

extension KopisAPIError {
    var asAppError: AppError {
        switch self {
        case .invalidURL:
            return .unknown(underlying: "invalid URL")

        case .transport(let urlError):
            switch urlError.code {
            case .notConnectedToInternet,
                 .networkConnectionLost,
                 .timedOut,
                 .dataNotAllowed,
                 .internationalRoamingOff:
                return .offline
            case .cancelled:
                return .unknown(underlying: "cancelled")
            default:
                return .unknown(underlying: urlError.localizedDescription)
            }

        case .http(let status):
            switch status {
            case 401, 403: return .unauthorized
            case 404:      return .notFound
            case 429:      return .rateLimited(retryAfter: nil)
            case 500...599: return .serverUnavailable
            default:        return .unknown(underlying: "HTTP \(status)")
            }

        case .parseFailed:
            return .decodingFailed
        }
    }
}

// MARK: - Firestore 에러 매핑

extension Error {
    /// Firestore/임의 Error 를 AppError 로 변환.
    /// FirebaseFirestore 의 NSError code 를 보고 분류.
    func asAppError() -> AppError {
        // 이미 AppError 면 그대로
        if let app = self as? AppError { return app }

        if let kopis = self as? KopisAPIError { return kopis.asAppError }

        let nsError = self as NSError

        // FirebaseFirestore 에러 도메인은 "FIRFirestoreErrorDomain"
        if nsError.domain == "FIRFirestoreErrorDomain" {
            switch nsError.code {
            case 7:  // permissionDenied
                return .permissionDenied
            case 14: // unavailable
                return .serverUnavailable
            case 16: // unauthenticated
                return .unauthorized
            case 5:  // notFound
                return .notFound
            default:
                return .unknown(underlying: nsError.localizedDescription)
            }
        }

        // URLError 직접 들어오면
        if let urlError = self as? URLError {
            return KopisAPIError.transport(urlError).asAppError
        }

        return .unknown(underlying: nsError.localizedDescription)
    }
}
